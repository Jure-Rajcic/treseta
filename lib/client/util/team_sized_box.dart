// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:app/constants.dart';
import 'package:flutter/material.dart';

class TeamSquare extends StatelessWidget {
  final int index;
  const TeamSquare({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: teams[index],
    );
  }
}
