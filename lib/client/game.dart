import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app/client/models/table_blueprint.dart';
import 'package:app/client/models/hand.dart';
import 'package:app/client/util/containers.dart';
import 'package:app/client/util/dialogs.dart';
import 'package:app/client/util/emoji_sized_box.dart';
import 'package:app/client/util/team_sized_box.dart';
import 'package:app/client/util/text_styles.dart';
import 'package:app/constants.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft]);

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: GamePage(),
  ));
}

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  bool locked = true;
  bool initialize = true;

  int whiteScore = 0;
  int blackScore = 0;
  late String playerId;

  late Socket socket;
  // late List<String> playableCards;
  int cnt = 0;

  List<Widget> table = [
    const SizedBox(),
    const SizedBox(),
    const SizedBox(),
    const SizedBox(),
  ];

  late final SharedPreferences prefs;
  List<String> cardsOnScreen = [];

  String reaction = 'x';
  @override
  void initState() {
    super.initState();

    Socket.connect(ip, gamePort).then((Socket socket) async {
      this.socket = socket;
      prefs = await SharedPreferences.getInstance();
      String gameID = prefs.getString('gameId')!;
      int playerId = prefs.getInt('playerId')!;
      Timer(
        Duration(seconds: 3 * playerId),
        () => socket.write('SOCKET_INFO#$gameID#$playerId'),
      );
      ServerSocket.bind(socket.address, socket.port).then((serverSocket) {
        serverSocket.listen((event) {
          event.listen((res) {
            List<String> l = String.fromCharCodes(res).split('#');
            if (l[0] == 'NEW') {
              List<String> playerCards = (json.decode(l[1]) as List<dynamic>)
                  .map((e) => e.toString())
                  .toList();

              Map<String, int> score = Map.from(json.decode(l[2]));
              extraPoints = Map.from(json.decode(l[3]));

              setState(() {
                hand = playerCards;
                blackScore = score['0']!;
                whiteScore = score['1']!;
              });
              return;
            }
            print(l);
            int currId = int.parse(l[0]);
            if (extraPoints.containsKey('$currId')) {
              List<String> values = extraPoints['$currId']!.split('-');
              String name = values[0];
              String emoji = emojis[int.parse(values[1])];
              String team = values[2] == '0' ? 'black' : 'white';
              String des = values[3];
              if (des != 'x') {
                String title = 'extra points for $team team';
                String description = 'player $name $emoji has $des';
                DialogType dt = prefs.getInt('team') == int.parse(values[2])
                    ? DialogType.SUCCES
                    : DialogType.INFO_REVERSED;
                showExtraPointsMessage(context, title.toLowerCase(),
                    description.toLowerCase(), dt);
              }
              extraPoints.remove('$currId');
            }

            setState(() => action = playerId == currId ? '⬆' : '🚫');
            if (l.length == 2) return;
            String playedCard = l[2];
            List<String> orderByPlayerId = (json.decode(l[3]) as List<dynamic>)
                .map((e) => e.toString())
                .toList();
            int i = orderByPlayerId.indexOf('$currId');
            int j = orderByPlayerId.indexOf('$playerId');
            int index = (i + 1 - j) % 4;
            Widget w = CardsOnTable.cardOnTable(playedCard, index);
            cardsOnScreen.add(playedCard);
            setState(() {
              table.add(w);
            });
            if (l[5] != 'x') {
              print('usaaaaaaaa');
              List<String> msg = l[5].split('-');
              print(msg);
              String name = msg[0];
              String emoji = emojis[int.parse(msg[1])];
              String reaction = reactions[int.parse(msg[2])];
              print('msg: $msg');
              String txt = 'player $name $emoji says $reaction';
              print('txt: $txt');
              showReactionMessage(context, txt);
              // showErrorMessage(context, 'xxx');
            }
            cnt++;
            if (cnt == 4) {
              cardsOnScreen.clear();
              cnt = 0;
              Timer(const Duration(milliseconds: 2500), () {
                setState(() {
                  table = [];
                  if (l[4] != 'x') {
                    action = playerId == int.parse(l[4]) ? '⬆' : '🚫';
                  }
                });

                if (hand.isEmpty) {
                  print('wanting new round');
                  socket.write('NEW_ROUND#$gameID');
                }
              });
            }
          });
        });
      });
    });
  }

  late List<String> hand = [];
  late Map<String, int> emojiMap = {};
  late int i;
  late Map<String, String> extraPoints = {};
  late Map<String, int> score = {};
  bool initialized = true;

  String action = '🚫';
  @override
  Widget build(BuildContext context) {
    if (initialize) {
      initialize = false;
      final arg =
          ModalRoute.of(context)!.settings.arguments as Map<dynamic, dynamic>;
      hand = (arg['playerIdCards'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();
      emojiMap = Map.from(arg['playerIdEmoji']);
      i = arg['i'];
      extraPoints = Map.from(arg['extraPoints']);
    }

    return Scaffold(
      backgroundColor: Colors.blue[100],
      resizeToAvoidBottomInset: false,
      body: Row(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("lib/client/assets/background.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: EmojiSquare(index: emojiMap['${(i + 2) % 4}']!),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      EmojiSquare(index: emojiMap['${(i + 1) % 4}']!),
                      Center(
                        child: SizedBox(
                          height: 150,
                          width: 250,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: table,
                          ),
                        ),
                      ),
                      EmojiSquare(index: emojiMap['${(i + 3) % 4}']!),
                    ],
                  ),
                  Hand(hand),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Containers.third(const TeamSquare(index: 0)),
                          Containers.main(
                            blackScore < 10
                                ? Row(
                                    children: [emojiNumbers[blackScore]],
                                  )
                                : Row(
                                    children: [
                                      emojiNumbers[(blackScore / 10).floor()],
                                      emojiNumbers[blackScore % 10]
                                    ],
                                  ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Containers.third(const TeamSquare(index: 1)),
                          Containers.main(
                            whiteScore < 10
                                ? Row(
                                    children: [emojiNumbers[whiteScore]],
                                  )
                                : Row(
                                    children: [
                                      emojiNumbers[(whiteScore / 10).floor()],
                                      emojiNumbers[whiteScore % 10]
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        child: Containers.emojiRounded(
                          TextButton(
                            child: Text(
                              action,
                              style: TextStyles.emojiStyle(),
                            ),
                            onPressed: () {
                              if (action == '⬆') {
                                if (!HandState.choice.mounted) {
                                  showInformationMessage(
                                      context, 'SELECT CARD TO THROW');
                                  return;
                                }
                                String choice =
                                    HandState.choice.widget.toMyString();
                                if (cardsOnScreen.isNotEmpty) {
                                  List<String> possibleCardsToThrow = [];
                                  for (String s in hand) {
                                    if (cardsOnScreen[0].substring(0, 1) ==
                                        s.substring(0, 1)) {
                                      possibleCardsToThrow.add(s);
                                    }
                                  }
                                  if (possibleCardsToThrow.isEmpty) {
                                    possibleCardsToThrow = hand;
                                  }
                                  if (!possibleCardsToThrow.contains(choice)) {
                                    showErrorMessage(context, 'BREAKING RULES');
                                    return;
                                  }
                                }

                                String gameId = prefs.getString('gameId')!;
                                int playerId = prefs.getInt('playerId')!;
                                setState(() {
                                  hand.remove(choice);
                                  action = '🚫';
                                });
                                String req =
                                    'THROW#$gameId#$playerId#${json.encode(hand)}#$choice#$reaction';
                                reaction = 'x';
                                socket.write(req);
                              } else {
                                showInformationMessage(
                                    context, 'WAIT FOR YOUR TURN');
                              }
                              HandState.choice.setPressed(false);
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 2.5 * width,
                        child: Containers.main(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Containers.lock(
                                TextButton(
                                  child: Text(
                                    '✍️',
                                    style: TextStyles.emojiStyle(),
                                  ),
                                  onPressed: () {
                                    if (locked) return;
                                    // TODO nkopirat istu funkciju
                                  },
                                ),
                                locked,
                              ),
                              IconButton(
                                icon: Icon(
                                  locked ? Icons.lock : Icons.lock_open,
                                  size: 2 * fontSize,
                                ),
                                onPressed: () =>
                                    setState(() => locked = !locked),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: height,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: reactions.map((emoji) {
                        return Containers.emojiRounded(
                          TextButton(
                            child: Text(
                              emoji,
                              style: TextStyles.emojiStyle(),
                            ),
                            onPressed: () {
                              // TODO obavjestit suigraca
                              String name = prefs.getString('name')!;
                              int emojiInd = prefs.getInt('emoji')!;
                              int reactionInd = reactions.indexOf(emoji);
                              String message = '$name-$emojiInd-$reactionInd';
                              setState(() {
                                reaction = message;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
