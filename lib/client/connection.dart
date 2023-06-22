import 'dart:io';

import 'package:app/client/game.dart';
import 'package:app/client/loby.dart';
import 'package:app/client/util/emoji_sized_box.dart';
import 'package:app/client/util/dialogs.dart';
import 'package:app/client/util/containers.dart';
import 'package:app/client/util/team_sized_box.dart';
import 'package:app/client/util/text_styles.dart';
import 'package:app/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft]);
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    routes: {
      '/': (context) => const ConnectionPage(),
      '/loby': (context) => const LobyPage(),
      '/game': (context) => const GamePage(),
    },
  ));
}

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({Key? key}) : super(key: key);

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  int teamInd = 0;
  int emojiInd = 0;
  final name = TextEditingController();
  final id = TextEditingController();
  final RegExp gameIdReg = RegExp(
    r'^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]):[0-9]+$',
  );
  bool loading = false;

  @override
  void dispose() {
    name.dispose();
    id.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        minimum: const EdgeInsets.all(50),
        child: loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: height,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Containers.main(
                          Text(
                            'INFO & TEAM & EMOJI',
                            style: TextStyles.main(),
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: Containers.main(
                            TextField(
                              maxLength: 12,
                              textAlign: TextAlign.center,
                              controller: name,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'USERNAME',
                                counterText: '',
                              ),
                              style: TextStyles.main(),
                            ),
                          ),
                        ),
                        Container(
                          color: Colors.blue,
                          width: width,
                          child: TextButton(
                            onPressed: () => setState(
                                () => teamInd = (teamInd + 1) % teams.length),
                            child: TeamSquare(
                              index: teamInd,
                            ),
                          ),
                        ),
                        Container(
                          color: Colors.blue,
                          width: width,
                          child: TextButton(
                            onPressed: () => setState(() =>
                                emojiInd = (emojiInd + 1) % emojis.length),
                            child: EmojiSquare(
                              index: emojiInd,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 450,
                    child: SizedBox(
                      height: height,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Containers.main(
                            Text(
                              'IP:PORT',
                              style: TextStyles.main(),
                            ),
                          ),
                          SizedBox(
                            height: height,
                            width: 5 * width,
                            child: Containers.main(
                              TextField(
                                maxLength: 20,
                                textAlign: TextAlign.center,
                                controller: id,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '109.31.27.53:3000',
                                  counterText: '',
                                ),
                                // ukljucujuci slike 28 * 28 npr a ne emojije ...
                                style: TextStyles.main(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Containers.second(
                    TextButton(
                      onPressed: () {
                        String description = '';
                        if (name.text.isEmpty) {
                          description += 'USERNAME CAN\'T BE EMPTY\n';
                        }
                        if (!gameIdReg.hasMatch(id.text)) {
                          description += 'INVALID IP/PORT';
                        }
                        if (description.isNotEmpty) {
                          showErrorMessage(context, description);
                        } else {
                          setState(() => loading = true);
                          Socket.connect(ip, connectionPort).then(
                            (Socket socket) {
                              String req =
                                  '${name.text}#${id.text}#$teamInd#$emojiInd';
                              socket.write(req);
                              socket.listen(
                                (res) async {
                                  String msg = String.fromCharCodes(res);
                                  if (msg == error) {
                                    setState(() => loading = false);
                                    String color =
                                        teamInd == 0 ? 'BLACK' : 'WHITE';
                                    showErrorMessage(
                                        context, '$color TEAM FULL');
                                  } else {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setString('name', name.text);
                                    await prefs.setInt('team', teamInd);
                                    await prefs.setInt('emoji', emojiInd);
                                    await prefs.setString('gameId', id.text);
                                    await prefs.setInt(
                                        'playerId', int.parse(msg));
                                    if (mounted) {
                                      await Navigator.pushNamed(
                                          context, '/loby');
                                    }
                                  }
                                },
                                onDone: (() => socket.destroy()),
                              );
                            },
                          );
                        }
                      },
                      child: Text(
                        'CONNECT ME',
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
