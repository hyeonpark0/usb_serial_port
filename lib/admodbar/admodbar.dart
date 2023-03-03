import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../provider/myProvider.dart';

Container AdmodBar(BuildContext context) {
  return Container(
    margin: EdgeInsets.only(top: 5),
    width: double.infinity,
    height: context.watch<AdmodState>().show ? 50 : 0,
    color: MyApp.my_white,
  );
}
