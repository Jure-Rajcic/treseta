import 'package:cloud_firestore/cloud_firestore.dart';

class ExtraPoints {
  static Future<String> check(
      String gameId, List<String> hand, int team) async {
    var gameRef = FirebaseFirestore.instance.collection('game').doc(gameId);
    Map<String, dynamic> data = (await gameRef.get()).data()!;
    Map<String, dynamic> score = data['score'];

    Map<String, int> family = {'B': 0, 'D': 0, 'K': 0, 'S': 0};
    Map<String, int> extra = {'1': 0, '2': 0, '3': 0};
    for (String card in hand) {
      String t = card.substring(0, 1);
      String n = card.substring(1, card.length);
      if (['1', '2', '3'].contains(n)) {
        extra[n] = extra[n]! + 1;
        family[t] = family[t]! + 1;
      }
    }
    String ret = '';
    int currPoints = 0;
    family.forEach((k, v) {
      if (v == 3) {
        ret = '$ret[$k] family, ';
        currPoints += 3;
      }
    });
    extra.forEach((k, v) {
      if (v >= 3) {
        if (v == 3) {
          String missing = '';
          List<String> l = ['B$k', 'D$k', 'K$k', 'S$k'];
          for (int i = 0; i < l.length && missing == ''; i++) {
            if (!hand.contains(l[i])) {
              missing = l[i].toUpperCase();
            }
          }
          ret = '${ret}three $k without $missing, ';
        } else {
          ret = '${ret}four $k, ';
        }
        currPoints += v;
      }
    });

    if (currPoints == 0) {
      return 'x';
    } else {
      score['$team'] = score['$team'] + currPoints;
      await gameRef.update({
        'score': score,
      });
      return ret.substring(0, ret.length - 2);
    }
  }
}
