import 'dart:io';
import 'dart:typed_data';

import 'package:app/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Connection {
  static const String subColection = 'players';
  static void handleConnection(Socket clientSocket) {
    clientSocket.listen((Uint8List data) async {
      // msg = name#$gameId#team#emoji'
      List<String> msg = String.fromCharCodes(data).split('#');
      String name = msg[0];
      String gameId = msg[1];
      int team = int.parse(msg[2]);
      int emoji = int.parse(msg[3]);

      var docRef = FirebaseFirestore.instance.collection('loby').doc(gameId);

      Map<int, int> teams = {};
      await docRef.collection(subColection).get().then((res) {
        var it = res.docs.iterator;
        while (it.moveNext()) {
          var player = it.current.data();
          teams[player['team']] = 1 + (teams[player['team']] ?? 0);
        }
      });

      teams[team] = 1 + (teams[team] ?? 0);

      if (teams.values.any((count) => count > 2)) {
        clientSocket.write(error);
        return;
      } else {
        var playersColection = await docRef.collection(subColection).get();
        int playerId = playersColection.docs.length;
        await docRef.collection(subColection).doc('$playerId').set({
          'name': name,
          'team': team,
          'emoji': emoji,
        });
        clientSocket.write(playerId.toString());
      }
    }, onDone: () => clientSocket.close());
  }
}
