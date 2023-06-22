import 'dart:convert';
import 'dart:io';

import 'package:app/constants.dart';
import 'package:app/server/extra_points.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Init {
  static Map<String, List<Socket>> clients = {};
  static void handleConnection(Socket clientSocket) {
    clientSocket.listen((event) async {
      List<String> req = String.fromCharCodes(event).split('#');
      String gameId = req[0];
      if (!clients.containsKey(gameId)) clients[gameId] = [];
      clients[gameId]!.add(clientSocket);
      String playerId = req[1];
      var doc = FirebaseFirestore.instance.collection('game').doc(gameId);
      if (!(await doc.get()).exists) {
        doc.set({
          'playerOrder': [{}, {}, {}, {}],
          'black': 0,
          'white': 1,
          'score': {'0': 0, '1': 0},
          'startingId': playerId,
          'current_turn': 1,
        });
        for (int i = 1; i <= 10; i++) {
          await doc.collection('turns').doc('${'$i'.padLeft(2, '0')}.').set({
            'playedCards': ['', '', '', ''],
            'points': 0,
            'belas': 0,
          });
        }
        await doc.collection('turns').doc('01.').update({
          'startingId': playerId,
        });
      }

      Map<String, dynamic> data = (await doc.get()).data()!;
      List<dynamic> playerOrder = data['playerOrder'];
      int black = data['black'];
      int white = data['white'];

      var docRef = FirebaseFirestore.instance.collection('loby').doc(gameId);
      var playerRef = docRef.collection('players').doc(playerId);
      var player = (await playerRef.get()).data()!;

      if (player['team'] == 0) {
        playerOrder[black].addAll(player);
        black += 2;
        await doc.update({'black': black});
      } else {
        playerOrder[white].addAll(player);
        white += 2;
        await doc.update({'white': white});
      }
      await doc.update({'playerOrder': playerOrder});
      if (!(black == 4 && white == 5)) return;
      await doc.update({
        'black': FieldValue.delete(),
        'white': FieldValue.delete(),
      });
      Init.startGame(playerOrder, gameId);
    });
  }

  static void startGame(List<dynamic> playerOrder, String gameId) async {
    var doc = FirebaseFirestore.instance.collection('game').doc(gameId);
    List<String> deck = [];
    for (String t in types) {
      for (String n in numbers) {
        deck.add('$t$n');
      }
    }

    Map<String, dynamic> playerIdCards = {};
    Map<String, dynamic> playerIdEmoji = {};
    Map<String, dynamic> extraPoints = {};
    List<String> orderByPlayerId = [];
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
      playerIdEmoji[playerId] = it.current['emoji'];
      orderByPlayerId.add(playerId);
      String name = it.current['name'];
      int emoji = it.current['emoji'];
      int team = it.current['team'];

      String des = await ExtraPoints.check(gameId, cards, team);
      extraPoints[playerId] = '$name-$emoji-$team-$des';
      it.current['cards'] = cards;
    }
    await doc.update({
      'playerOrder': playerOrder,
      'orderByPlayerId': orderByPlayerId,
    });
    for (Socket c in clients[gameId]!) {
      String res =
          '${json.encode(playerIdCards)}#${json.encode(playerIdEmoji)}#${json.encode(orderByPlayerId)}#${json.encode(extraPoints)}';
      c.write(res);
    }
    if (clients.containsKey(gameId)) {
      // clients.remove(gameId);
    }
  }
}
