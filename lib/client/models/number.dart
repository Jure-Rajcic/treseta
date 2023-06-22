// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await SystemChrome.setPreferredOrientations(
//       [DeviceOrientation.landscapeLeft]);
//   runApp(
//     const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: ScoreNumber(
//         num: 1,
//       ),
//     ),
//   );
// }

class ScoreNumber extends StatelessWidget {
  final int num;
  const ScoreNumber({
    Key? key,
    required this.num,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            color: Colors.blueGrey,
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: Center(
          child: Text(
            '$num',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}
