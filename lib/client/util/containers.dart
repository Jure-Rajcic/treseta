import 'package:app/constants.dart';
import 'package:flutter/material.dart';

class Containers {
  static StatelessWidget main(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(width: 3.0, color: Colors.black),
        color: Colors.white,
      ),
      child: Center(
        child: child,
      ),
    );
  }

  static StatelessWidget second(Widget child) {
    return Container(
      height: height,
      width: 550,
      decoration: BoxDecoration(
        border: Border.all(width: 3.0, color: Colors.blue),
        color: Colors.blue[300],
      ),
      child: Center(
        child: child,
      ),
    );
  }

  static StatelessWidget third(Widget child) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: Colors.blue),
        color: Colors.blue[300],
      ),
      child: Center(
        child: child,
      ),
    );
  }

  static StatelessWidget emojiRounded(Widget child) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: Colors.blue),
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: child,
      ),
    );
  }

  static Stack lock(Widget child, bool locked) {
    return Stack(
      alignment: Alignment.center,
      children: [
        emojiRounded(child),
        locked
            ? const Icon(
                Icons.block,
                size: 3 * fontSize,
                color: Colors.black,
              )
            : Container(),
      ],
    );
  }
}

class ContainerSecond extends StatelessWidget {
  final Widget child;
  const ContainerSecond({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: 550,
      decoration: BoxDecoration(
        border: Border.all(width: 3.0, color: Colors.blue),
        color: Colors.blue[300],
      ),
      child: Center(
        child: child,
      ),
    );
  }
}
