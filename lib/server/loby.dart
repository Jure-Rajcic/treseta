import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

class Loby {
  static const String subColection = 'players';
  static void handleConnection(Socket clientSocket) {
    clientSocket.listen((Uint8List data) async {
      // data = gameId#playerId
      List<String> information = String.fromCharCodes(data).split('#');
      String gameId = information[0];
      String playerId = information[1];

      String playerIp = clientSocket.remoteAddress.address;
      String playerPort = clientSocket.remotePort.toString();

      var docRef = FirebaseFirestore.instance.collection('loby').doc(gameId);
      var playerRef = docRef.collection(subColection).doc(playerId);

      await playerRef.update({
        'ip': playerIp,
        'port': playerPort,
        'playerId': playerId,
      });

      String msg = '';
      await docRef.collection(subColection).get().then((res) {
        var it = res.docs.iterator;
        while (it.moveNext()) {
          var player = it.current.data();
          msg += '${player['team']}#${player['emoji']}#';
        }
      });
      msg = msg.substring(0, msg.length - 1);
      // msg = team#emoji#team#emoji...
      broadcast(gameId, msg);
    }, onDone: () => clientSocket.close());
  }

  static void broadcast(String gameId, String msg) async {
    var docRef = FirebaseFirestore.instance.collection('loby').doc(gameId);
    await docRef.collection(subColection).get().then((res) {
      var it = res.docs.iterator;
      while (it.moveNext()) {
        var player = it.current.data();
        String ip = player['ip'];
        String port = player['port'];
        sendMessageToSocket(ip, port, msg);
      }
    });
  }

  static void sendMessageToSocket(String ip, String port, String msg) {
    Socket.connect(ip, int.parse(port)).then((Socket clientSocket) {
      clientSocket.write(msg);
    });
  }
}
