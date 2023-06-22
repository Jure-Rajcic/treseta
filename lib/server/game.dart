import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app/constants.dart';
import 'package:app/server/extra_points.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  static Map<String, int> newGameCounter = {};
  static Map<String, int> playerCounter = {};
  static void handleConnection(Socket clientSocket) {
    clientSocket.listen((Uint8List event) async {
      List<String> req = String.fromCharCodes(event).split('#');
      switch (req[0]) {
        case 'SOCKET_INFO':
          String gameId = req[1];
          String playerId = req[2];

          var gameRef =
              FirebaseFirestore.instance.collection('game').doc(gameId);
          Map<String, dynamic> data = (await gameRef.get()).data()!;
          List<dynamic> playerOrder = data['playerOrder'];

          Map<String, dynamic> player = playerOrder[int.parse(playerId)];
          player['ip'] = clientSocket.remoteAddress.address;
          player['port'] = clientSocket.remotePort.toString();
          await gameRef.update({
            'playerOrder': playerOrder,
          });
          if (!playerCounter.containsKey(gameId)) playerCounter[gameId] = 0;
          playerCounter[gameId] = playerCounter[gameId]! + 1;
          if (playerCounter[gameId] != 4) return;
          playerCounter.remove(gameId); // ZVONE JE REKA INTERNA MEMORIJA

          String startingId = data['startingId'];
          List<String> cards = [];

          for (var player in playerOrder) {
            if (player['playerId'] == startingId) {
              cards = (player['cards'] as List<dynamic>)
                  .map((e) => e.toString())
                  .toList();
            }
          }
          Game.sendCardsToStartingPlayer(data, cards);
          break;
        case 'THROW':
          String gameId = req[1];
          String currPlayerId = req[2];
          List<String> hand = (json.decode(req[3]) as List<dynamic>)
              .map((e) => e.toString())
              .toList();
          String playedCard = req[4];
          String reaction = req[5];
          var gameRef =
              FirebaseFirestore.instance.collection('game').doc(gameId);
          Map<String, dynamic> data = (await gameRef.get()).data()!;
          List<dynamic> playerOrder = data['playerOrder'];
          List<dynamic> orderByPlayerId = data['orderByPlayerId'];

          int i = orderByPlayerId.indexOf(currPlayerId);
          playerOrder[i]['cards'] = hand;
          i = (i - 1) % 4;
          await gameRef.update({
            'playerOrder': playerOrder,
            'startingId': orderByPlayerId[i],
          });
          var nextPlayer = playerOrder[i];
          String nextPlayerId = nextPlayer['playerId'];
          List<String> nextPlayerCards = (nextPlayer['cards'] as List<dynamic>)
              .map((e) => e.toString())
              .toList();

          int currentTurn = data['current_turn'];
          var turnRef = gameRef
              .collection('turns')
              .doc('${'$currentTurn'.padLeft(2, '0')}.');
          data = (await turnRef.get()).data()!;
          List<String> playedCards = (data['playedCards'] as List<dynamic>)
              .map((e) => e.toString())
              .toList();
          i = 0;
          while (playedCards[i] != '') {
            i++;
          }
          playedCards[i] = playedCard;
          List<String> possibleCardsToThrow = [];
          for (String s in nextPlayerCards) {
            if (playedCards[0].substring(0, 1) == s.substring(0, 1)) {
              possibleCardsToThrow.add(s);
            }
          }
          if (possibleCardsToThrow.isNotEmpty) {
            nextPlayerCards = possibleCardsToThrow;
          }
          Map<String, dynamic> winer = {};
          if (i == 3) {
            String t = '';
            String n = '';
            for (String s in playedCards) {
              String tCurr = s.substring(0, 1);
              String nCurr = s.substring(1, s.length);
              if (t == '' && n == '' ||
                  (t == tCurr && numbers.indexOf(nCurr) < numbers.indexOf(n))) {
                t = tCurr;
                n = nCurr;
              }
            }
            winer = playerOrder[(orderByPlayerId.indexOf(data['startingId']) -
                    playedCards.indexOf('$t$n')) %
                4];

            await gameRef
                .collection('turns')
                .doc('${'$currentTurn'.padLeft(2, '0')}.')
                .update({
              'startingId': winer['playerId'],
            });

            int belas = data['belas'];
            int points = data['points'];
            for (String pc in playedCards) {
              String num = pc.substring(1, pc.length);
              if (num == '1') {
                points++;
              } else if (numbers.indexOf(num) <= 5) {
                belas++;
              }
            }
            await turnRef.update({
              'belas': belas,
              'points': points,
              'team': winer['team'],
            });

            if (currentTurn == 11) {
              currentTurn = 0;
            }
            gameRef.update({
              'current_turn': currentTurn + 1,
            });
            nextPlayerCards = (winer['cards'] as List<dynamic>)
                .map((e) => e.toString())
                .toList();
          }
          await turnRef.update({
            'playedCards': playedCards,
          });

          String s = winer.isNotEmpty
              ? '$nextPlayerId#${json.encode(nextPlayerCards)}#$playedCard#${json.encode(orderByPlayerId.map((e) => e.toString()).toList())}#${winer['playerId']}'
              : '$nextPlayerId#${json.encode(nextPlayerCards)}#$playedCard#${json.encode(orderByPlayerId.map((e) => e.toString()).toList())}#x';
          s += '#$reaction';
          for (var player in playerOrder) {
            String ip = player['ip'];
            String port = player['port'];
            await Socket.connect(ip, int.parse(port))
                .then((Socket clientSocket) {
              clientSocket.write(s);
            });
          }
          break;
        case 'NEW_ROUND':
          String gameId = req[1];
          if (!newGameCounter.containsKey(gameId)) {
            newGameCounter[gameId] = 0;
          }
          newGameCounter[gameId] = newGameCounter[gameId]! + 1;
          if (newGameCounter[gameId] != 4) return;
          newGameCounter[gameId] = 0;
          var gameRef =
              FirebaseFirestore.instance.collection('game').doc(gameId);
          Map<String, dynamic> data = (await gameRef.get()).data()!;
          Map<String, dynamic> score = data['score'];

          Map<String, int> black = {'points': 0, 'belas': 0};
          Map<String, int> white = {'points': 0, 'belas': 0};
          for (int i = 1; i <= 10; i++) {
            var x = (await gameRef
                    .collection('turns')
                    .doc('${'$i'.padLeft(2, '0')}.')
                    .get())
                .data();
            int team = x!['team'];
            Map m = team == 0 ? black : white;
            m['points'] = m['points'] + x['points'];
            m['belas'] = m['belas'] + x['belas'];
            if (i == 10) {
              m['points'] = m['points'] + 1;
            }
            print('for turn $i : $m');
          }
          white['points'] = white['points']! + (white['belas']! / 3).floor();
          black['points'] = black['points']! + (black['belas']! / 3).floor();

          score['0'] = score['0'] + black['points'];
          score['1'] = score['1'] + white['points'];

          List<dynamic> orderByPlayerId = data['orderByPlayerId'];
          String startingId = data['startingId'];
          int i = orderByPlayerId.indexOf(startingId);
          // i = (i + 1) % 4;
          startingId = orderByPlayerId[i];

          List<dynamic> playerOrder = data['playerOrder'];
          List<String> deck = [];
          for (String t in types) {
            for (String n in numbers) {
              deck.add('$t$n');
            }
          }

          Map<String, dynamic> playerIdCards = {};
          Map<String, dynamic> extraPoints = {};
          deck.shuffle();
          var it = playerOrder.iterator;
          while (it.moveNext()) {
            List<String> cards = [];
            for (int i = 0; i < 10; i++) {
              cards.add(deck.removeAt(0));
            }
            cards.sort((s1, s2) {
              String t1 = s1.substring(0, 1);
              String t2 = s2.substring(0, 1);
              int x = t1.compareTo(t2);
              if (x != 0) return x;
              int n1 = int.parse(s1.substring(1, s1.length));
              int n2 = int.parse(s2.substring(1, s2.length));
              return n1.compareTo(n2);
            });
            String playerId = it.current['playerId'];
            playerIdCards[playerId] = cards;
            String name = it.current['name'];
            int emoji = it.current['emoji'];
            int team = it.current['team'];

            String des = await ExtraPoints.check(gameId, cards, team);
            extraPoints[playerId] = '$name-$emoji-$team-$des';
            it.current['cards'] = cards;
          }
          await gameRef.update({
            'playerOrder': playerOrder,
            'score': score,
            'startingId': startingId,
          });

          for (var player in playerOrder) {
            String ip = player['ip'];
            String port = player['port'];
            await Socket.connect(ip, int.parse(port))
                .then((Socket clientSocket) {
              List<String> playerCards = (player['cards'] as List<dynamic>)
                  .map((e) => e.toString())
                  .toList();
              clientSocket.write(
                  'NEW#${json.encode(playerCards)}#${json.encode(score)}#${json.encode(extraPoints)}');
            });
          }
          await Future.delayed(const Duration(seconds: 5));
          var startingPlayer = playerOrder[i];
          List<String> startingPlayerCards =
              (startingPlayer['cards'] as List<dynamic>)
                  .map((e) => e.toString())
                  .toList();
          String ip = startingPlayer['ip'];
          String port = startingPlayer['port'];
          Socket.connect(ip, int.parse(port)).then((Socket clientSocket) {
            clientSocket
                .write('$startingId#${json.encode(startingPlayerCards)}');
          });
          break;
      }
    });
  }

  static void sendCardsToStartingPlayer(
      Map<String, dynamic> data, List<String> cards) {
    List<dynamic> playerOrder = data['playerOrder'];
    String startingId = data['startingId'];
    for (var player in playerOrder) {
      String ip = player['ip'];
      String port = player['port'];
      Socket.connect(ip, int.parse(port)).then((Socket clientSocket) {
        clientSocket.write('$startingId#${json.encode(cards)}');
      });
    }
  }
}
