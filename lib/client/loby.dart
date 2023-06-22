import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app/client/util/containers.dart';
import 'package:app/client/util/emoji_sized_box.dart';
import 'package:app/client/util/team_sized_box.dart';
import 'package:app/client/util/text_styles.dart';
import 'package:app/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft]);

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LobyPage(),
    ),
  );
}

class LobyPage extends StatefulWidget {
  const LobyPage({Key? key}) : super(key: key);

  @override
  State<LobyPage> createState() => _LobyPageState();
}

class _LobyPageState extends State<LobyPage> {
  String? gameId;
  int? playerId;
  List<Widget> blackList = [];
  List<Widget> whiteList = [];

  @override
  void initState() {
    super.initState();
    initAsync();
    Socket.connect(ip, lobyPort).then((Socket socket) {
      ServerSocket.bind(socket.address, socket.port).then((serverSocket) {
        serverSocket.listen((event) {
          event.listen((res) async {
            //res =  team#emoji#team#emoji...
            List<String> data = String.fromCharCodes(res).split('#');
            List<Widget> bl = [Containers.third(const TeamSquare(index: 0))];
            List<Widget> wl = [Containers.third(const TeamSquare(index: 1))];

            for (var i = 0; i < data.length; i += 2) {
              List<Widget> curr = int.parse(data[i]) == 0 ? bl : wl;
              curr.add(const SizedBox(width: 20));
              curr.add(
                Containers.third(EmojiSquare(index: int.parse(data[i + 1]))),
              );
              setState(() {
                blackList = bl;
                whiteList = wl;
              });
            }
            if (wl.length + bl.length == 2 * (1 + 2 * (1 + 1))) {
              Socket.connect(ip, initPort).then((Socket s) {
                Timer(
                  Duration(seconds: 5 * playerId!),
                  () => s.write('$gameId#$playerId'),
                );
                s.listen((event) async {
                  List<String> l = String.fromCharCodes(event).split('#');
                  await Navigator.popAndPushNamed(context, '/game', arguments: {
                    'playerIdCards': json.decode(l[0])['$playerId'],
                    'playerIdEmoji': json.decode(l[1]),
                    'i': json
                        .decode(l[2])
                        .map((e) => e.toString())
                        .toList()
                        .indexOf('$playerId'),
                    'extraPoints': json.decode(l[3]),
                  });
                });
              });
            }
          });
        });
      });
      String req = '$gameId#$playerId';
      socket.write(req);
    });
  }

  void initAsync() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      gameId = prefs.getString('gameId');
      playerId = prefs.getInt('playerId');
    });
  }

  String fadingText = 'WAITING 4 PLAYERS ...';
  @override
  Widget build(BuildContext context) {
    if (blackList.length + whiteList.length >= 2 * (1 + 2 * (1 + 1))) {
      // TODO ovo neradi neznam zasto??? pbrobaj s gornnjim uvjetom uvik true
      setState(() {
        fadingText = 'STARTING GAME ...';
      });
    }
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: SafeArea(
        minimum: const EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(
              child: SizedBox(
                height: height,
                width: 5 * width,
                child: Containers.main(
                  Text(
                    gameId!,
                    style: TextStyles.main(),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 4 * width,
              height: height,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: blackList.length,
                itemBuilder: (context, index) {
                  return blackList[index];
                },
              ),
            ),
            SizedBox(
              width: 4 * width,
              height: height,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: whiteList.length,
                itemBuilder: (context, index) {
                  return whiteList[index];
                },
              ),
            ),
            Containers.second(
              Center(
                child: FadingText(
                  fadingText, // TODO prominit u GAME INIT kad imam 4 igraca (nez zasto nece s setStateom())
                  style: TextStyles.main(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
