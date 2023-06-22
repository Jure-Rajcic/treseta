import 'dart:io';

import 'package:app/client/models/number.dart';
import 'package:flutter/material.dart';

// backend
final ip = InternetAddress.anyIPv4;
const int connectionPort = 4567;
const int lobyPort = 4568;
const int initPort = 4569;
const int gamePort = 4570;

List<Color> teams = [Colors.black, Colors.white];
List<String> emojis = ['😄', '😁', '😆', '😅', '😂', '🤣', '🥲', '😍', '🥰'];

// frontend
const double fontSize = 15;
const double height = 60;
const double width = 60;
const String error = 'error';

const List<ScoreNumber> emojiNumbers = [
  ScoreNumber(num: 0),
  ScoreNumber(num: 1),
  ScoreNumber(num: 2),
  ScoreNumber(num: 3),
  ScoreNumber(num: 4),
  ScoreNumber(num: 5),
  ScoreNumber(num: 6),
  ScoreNumber(num: 7),
  ScoreNumber(num: 8),
  ScoreNumber(num: 9),
];

const List<String> reactions = ["👊", "🫵", "🫳"];
List<String> types = ['B', 'D', 'K', 'S'];
List<String> numbers = ['3', '2', '1', '13', '12', '11', '7', '6', '5', '4'];
