import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

class HomeScreen extends StatefulWidget {
  static const Color my_white = Color(0xFFDDDDDD);
  static const Color my_darkblue = Color(0xFF222831);
  static const Color my_blue = Color(0xFF30475E);
  static const Color my_red = Color(0xFFF05454);

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UsbPort? _port;
  UsbDevice? _device;
  String _status = "Idle";

  List<Widget> _ports = [];
  List<Widget> _serialData = [];

  StreamSubscription<String>? _subscription;
  Transaction<String>? _transaction;

  TextEditingController _textController = TextEditingController();

  //terminal
  String? TerminalText;
  final ScrollController _scrollController = ScrollController();

  Future<bool> _openPort(device) async {
    _serialData.clear();

    if (_port != null) {
      _port!.close();
      _port = null;
    }

    if (device == null) {
      _device = null;
      setState(() {
        _status = "Disconnected";
      });
      return true;
    }

    _port = await device.create();
    if (await (_port!.open()) != true) {
      setState(() {
        _status = "Failed to open port";
      });
      return false;
    }
    _device = device;

    await _port!.setDTR(true);
    await _port!.setRTS(true);
    await _port!.setPortParameters(
        9600, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    _transaction = Transaction.stringTerminated(
        _port!.inputStream as Stream<Uint8List>, Uint8List.fromList([13, 10]));

    _subscription = _transaction!.stream.listen((String line) {
      setState(() {
        _serialData.add(Text(line));
        if (_serialData.length > 20) {
          _serialData.removeAt(0);
        }
      });
    });

    setState(() {
      _status = "Connected";
    });
    return true;
  }

  String getDateToString() {
    var date = DateTime.fromMillisecondsSinceEpoch(
        DateTime.now().millisecondsSinceEpoch);
    return date.hour.toString().padLeft(2, '0') +
        ":" +
        date.minute.toString().padLeft(2, '0') +
        ":" +
        date.second.toString().padLeft(2, '0') +
        "." +
        date.millisecond.toString().padLeft(3, '0');
  }

  void _getPorts() async {
    _ports = [];
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (!devices.contains(_device)) {
      _openPort(null);
    }

    TerminalText =
        TerminalText == null ? "" : "$TerminalText" + "${getDateToString()}\n";
    print(devices);

    devices.forEach((device) {
      _ports.add(ListTile(
          leading: Icon(Icons.usb),
          title: Text(device.productName!),
          subtitle: Text(device.manufacturerName!),
          trailing: ElevatedButton(
            child: Text(_device == device ? "Disconnect" : "Connect"),
            onPressed: () {
              _openPort(_device == device ? null : device).then((res) {
                _getPorts();
              });
            },
          )));
    });
    setState(() {
      print(_ports);
      _scrollDown();
    });
  }

  ///맨 밑으로 자동 포커스
  void _scrollDown() {
    // _scrollController.animateTo(0.0,
    //     duration: Duration(milliseconds: 300), curve: Curves.easeOutSine);
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  void initState() {
    super.initState();

    UsbSerial.usbEventStream!.listen((UsbEvent event) {
      _getPorts();
    });

    _getPorts();
  }

  @override
  void dispose() {
    super.dispose();
    _openPort(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terminal'),
        actions: [
          IconButton(
              onPressed: () {
                _getPorts();
              },
              icon: Icon(Icons.usb)),
          IconButton(onPressed: () {}, icon: Icon(Icons.delete_rounded)),
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: Icon(Icons.add_circle)),
        ],
        backgroundColor: HomeScreen.my_darkblue,
      ),
      drawer: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Drawer Header'),
              ),
              ListTile(
                title: const Text('Item 1'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Item 2'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
            ],
          ),
        ),
      ),
      backgroundColor: HomeScreen.my_darkblue,
      body: Column(
        children: [
          Expanded(
            flex: 11,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border.all(color: HomeScreen.my_white),
                  borderRadius: BorderRadius.circular(8.0)),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Text(
                  (TerminalText == null) ? "" : "$TerminalText",
                  style: TextStyle(color: HomeScreen.my_white),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: TextField(
                    maxLines: 1,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: HomeScreen.my_red),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide:
                            BorderSide(width: 1, color: Colors.redAccent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide:
                            BorderSide(width: 1, color: Colors.redAccent),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                    style: TextStyle(color: HomeScreen.my_white),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: Icon(Icons.send_rounded),
                    onPressed: _port == null
                        ? null
                        : () async {
                            if (_port == null) {
                              return;
                            }
                            String data = _textController.text + "\r\n";
                            await _port!
                                .write(Uint8List.fromList(data.codeUnits));
                            _textController.text = "";
                          },
                  ),
                )
              ],
            ),
          ),
        ],
      ),

      // Text(
      //     _ports.length > 0
      //         ? "Available Serial Ports"
      //         : "No serial devices available",
      //     style: Theme.of(context).textTheme.headline6),
      // Text("Result Data", style: Theme.of(context).textTheme.headline6),
    );
  }
}
