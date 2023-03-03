import 'dart:async';

import 'package:flutter/material.dart';

import '../admodbar/admodbar.dart';
import '../main.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({Key? key}) : super(key: key);

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
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
        title: Text("Devices"),
        backgroundColor: MyApp.my_darkblue,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListTile(
              title: Text(
                'device',
                style: TextStyle(color: MyApp.my_white),
              ),
              subtitle: Text('rs232'),
              trailing: IconButton(
                color: MyApp.my_white,
                icon: Icon(Icons.add_circle),
                onPressed: () {},
              ),
            ),
          ),
          AdmodBar(context),
        ],
      ),
    );
  }
}
