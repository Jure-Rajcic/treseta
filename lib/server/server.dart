import 'dart:io';

import 'package:app/constants.dart';
import 'package:app/server/connection.dart';
import 'package:app/server/game.dart';
import 'package:app/server/init.dart';
import 'package:app/server/loby.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft]);
  runApp(const MaterialApp(home: Server()));
}

class Server extends StatefulWidget {
  const Server({Key? key}) : super(key: key);

  @override
  State<Server> createState() => _Server();
}

class _Server extends State<Server> {
  String title = "Server running status: ❌";
  String startButtonText = "Start server";
  String closeButtonText = "Close server";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: Center(
        child: SizedBox(
          width: 500,
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 50.0,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: ButtonTheme(
                        minWidth: 400,
                        height: 100,
                        child: TextButton(
                          onPressed: () => startServer(),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          child: Text(startButtonText),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: ButtonTheme(
                        minWidth: 400,
                        height: 100,
                        child: TextButton(
                          onPressed: () => closeServer(),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          child: Text(closeButtonText),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  late ServerSocket connectioSocket;
  late ServerSocket lobySocket;
  late ServerSocket gameSocket;
  late ServerSocket initSocket;
  void startServer() {
    setState(() => title = '${title.substring(0, title.length - 1)}✅');
    ServerSocket.bind(ip, connectionPort).then(
      (ServerSocket socket) {
        connectioSocket = socket;
        socket.listen(
          (clientSocket) => Connection.handleConnection(clientSocket),
        );
      },
    );
    ServerSocket.bind(ip, lobyPort).then(
      (ServerSocket socket) {
        lobySocket = socket;
        socket.listen(
          (clientSocket) => Loby.handleConnection(clientSocket),
        );
      },
    );
    ServerSocket.bind(ip, initPort).then(
      (ServerSocket socket) {
        initSocket = socket;
        socket.listen(
          (clientSocket) => Init.handleConnection(clientSocket),
        );
      },
    );
    ServerSocket.bind(ip, gamePort).then(
      (ServerSocket socket) {
        gameSocket = socket;
        socket.listen(
          (clientSocket) => Game.handleConnection(clientSocket),
        );
      },
    );
  }

  void closeServer() {
    setState(() => title = '${title.substring(0, title.length - 1)}❌');
    connectioSocket.close();
    lobySocket.close();
    gameSocket.close();
    initSocket.close();
  }
}
