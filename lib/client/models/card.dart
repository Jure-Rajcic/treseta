import 'package:app/client/models/hand.dart';
import 'package:flutter/material.dart';

class PlayingCard extends StatefulWidget {
  final String t; // type of card
  final String s; // strength of card

  const PlayingCard({
    Key? key,
    required this.t,
    required this.s,
  }) : super(key: key);

  @override
  State<PlayingCard> createState() => PlayingCardState();

  String toMyString() {
    return '$t$s';
  }
}

class PlayingCardState extends State<PlayingCard> {
  bool pressed = false;

  void setPressed(bool b) => setState(() => pressed = b);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        height: 200,
        width: 150,
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: Image.asset(
            'lib/client/assets/card-images/${widget.t}${widget.s}.png',
            color: Colors.grey[200],
            // ovo cemo iskoristi za akuzu
            colorBlendMode: pressed ? BlendMode.difference : BlendMode.darken,
          ),
        ),
      ),
      onTap: () {
        if (HandState.choice.mounted) {
          HandState.choice.setPressed(false);
        }
        HandState.choice = this;
        setPressed(true);
      }, // TODO on hold show card info, type, strength, points
    );
  }
}
