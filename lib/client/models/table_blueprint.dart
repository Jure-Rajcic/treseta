import 'package:app/client/models/card.dart';
import 'package:flutter/material.dart';

class CardsOnTable {
  static Widget cardOnTable(String playedCard, int index) {
    String t = playedCard.substring(0, 1);
    String s = playedCard.substring(1, playedCard.length);
    final PlayingCard pc = PlayingCard(t: t, s: s);

    switch (index) {
      case 0:
        return TableCard(
          bottom: 0,
          left: 85,
          angle: 0,
          child: pc,
        );
      case 1:
        return TableCard(
          bottom: 40,
          left: 20,
          angle: 0.6,
          child: pc,
        );
      case 2:
        return TableCard(
          top: -10,
          right: 90,
          angle: 2.1,
          child: pc,
        );
      default:
        return TableCard(
          bottom: 0,
          right: 30,
          angle: 2.1,
          child: pc,
        );
    }
  }
}

// ignore: must_be_immutable
class TableCard extends StatelessWidget {
  TableCard(
      {Key? key,
      this.top,
      this.left,
      this.bottom,
      this.right,
      required this.child,
      required this.angle})
      : super(key: key);

  double? top = 0;
  double? left = 0;
  double? bottom = 0;
  double? right = 0;
  final double angle;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      bottom: bottom,
      right: right,
      height: 100,
      child: FittedBox(
        fit: BoxFit.fitHeight,
        child: Transform.rotate(
          angle: angle,
          child: child,
        ),
      ),
    );
  }
}
