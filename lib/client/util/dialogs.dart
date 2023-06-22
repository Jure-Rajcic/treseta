import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

showErrorMessage(dynamic context, String description) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.ERROR,
    title: 'ERROR',
    desc: description,
    btnOkOnPress: () {},
    btnOkColor: Colors.blue[400],
  ).show();
}

showInformationMessage(dynamic context, String description) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.INFO_REVERSED,
    title: 'ILEGAL ACTION',
    desc: description,
    btnOkOnPress: () {},
    btnOkColor: Colors.blue[400],
  ).show();
}

showExtraPointsMessage(
    dynamic context, String title, String description, DialogType dt) {
  AwesomeDialog(
    context: context,
    dialogType: dt,
    title: title,
    desc: description,
    btnOkOnPress: () {},
    btnOkColor: Colors.blue[400],
  ).show();
}

showReactionMessage(dynamic context, String txt) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.WARNING,
    title: txt,
    // desc: txt,
    btnOkOnPress: () {},
    btnOkColor: Colors.blue[400],
  ).show();
}
