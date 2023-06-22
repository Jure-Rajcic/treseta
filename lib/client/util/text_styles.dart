import 'package:app/constants.dart';
import 'package:flutter/material.dart';

class TextStyles extends TextStyle {
  static TextStyle main() {
    return const TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
  }

  static TextStyle emojiStyle() {
    return const TextStyle(
      fontSize: 1.4 * fontSize,
    );
  }
}
