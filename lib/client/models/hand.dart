import 'dart:math';

import 'package:app/client/models/card.dart';
import 'package:flutter/material.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await SystemChrome.setPreferredOrientations(
//       [DeviceOrientation.landscapeLeft]);
//   runApp(
//     const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Hand(),
//     ),
//   );
// }

// ignore: must_be_immutable
class Hand extends StatefulWidget {
  const Hand(this.hand, {Key? key}) : super(key: key);
  final List<String> hand;
  @override
  State<Hand> createState() => HandState();
}

class HandState extends State<Hand> {
  static List<PlayingCard> cards = [];
  static PlayingCardState choice = PlayingCardState();

  @override
  Widget build(BuildContext context) {
    cards = [];
    for (String string in widget.hand) {
      String t = string.substring(0, 1);
      String s = string.substring(1, string.length);
      cards.add(PlayingCard(t: t, s: s));
    }
    return Center(
      child: SizedBox(
        width: 500,
        height: 120,
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: Stack(
            children: [
              ...List.generate(
                cards.length,
                (index) => Transform.rotate(
                  angle: index / cards.length -
                      (cards.length == 1
                          ? 0
                          : pi / (cards.length <= 5 ? 10 : 5)),
                  child: Container(
                    margin: EdgeInsets.only(left: index * 35.0),
                    child: cards[index],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
