import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_usb_serial_1/provider/myProvider.dart';
import 'package:test_usb_serial_1/screen/terminal_page.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<AdmodState>(create: (_) => AdmodState())
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  static const Color my_white = Color(0xFFDDDDDD);
  static const Color my_darkblue = Color(0xFF222831);
  static const Color my_blue = Color(0xFF30475E);
  static const Color my_red = Color(0xFFF05454);

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TerminalPage(),
      theme: ThemeData(
          appBarTheme: AppBarTheme(color: my_darkblue),
          iconTheme: IconThemeData(color: my_white),
          drawerTheme: DrawerThemeData(backgroundColor: my_white),
          scaffoldBackgroundColor: my_darkblue),
    );
  }
}
