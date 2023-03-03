import 'dart:async';

import 'package:flutter/cupertino.dart';

class AdmodState with ChangeNotifier {
  bool show = true;
  DateTime dt = DateTime.now();

  CheckTimeout() async {
    show = false;
    dt = DateTime.now();

    Timer(Duration(seconds: 5), () {
      show = true;
    });
  }
}
