// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:app/constants.dart';
import 'package:flutter/material.dart';

class EmojiSquare extends StatelessWidget {
  final int index;
  const EmojiSquare({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2),
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(20))),
      child: Center(
        child: Text(
          emojis[index],
          style: const TextStyle(
            fontSize: 30,
          ),
        ),
      ),
    );
  }
}
