import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_usb_serial_1/main.dart';

import '../admodbar/admodbar.dart';
import '../provider/myProvider.dart';

class AdPaymentPage extends StatefulWidget {
  const AdPaymentPage({Key? key}) : super(key: key);

  @override
  State<AdPaymentPage> createState() => _AdPaymentPageState();
}

class _AdPaymentPageState extends State<AdPaymentPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Gift'),
        ),
        body: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                    height: 100,
                    color: MyApp.my_blue,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    width: double.infinity,
                    child: TextButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              MyApp.my_darkblue)),
                      onPressed: () {
                        setState(() {
                          context.read<AdmodState>().CheckTimeout();
                        });
                      },
                      child: Text('광고 제거'),
                    ),
                  ),
                ],
              ),
            ),
            AdmodBar(context),
          ],
        ));
  }
}
