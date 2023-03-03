import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:test_usb_serial_1/main.dart';
import 'package:test_usb_serial_1/screen/devices_page.dart';
import 'package:test_usb_serial_1/screen/settine_page.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

import '../admodbar/admodbar.dart';
import 'adpayment_page.dart';
import 'infomation_page.dart';

class TerminalPage extends StatefulWidget {
  const TerminalPage({Key? key}) : super(key: key);

  @override
  State<TerminalPage> createState() => _TerminalPageState();
}

class _TerminalPageState extends State<TerminalPage> {
  UsbPort? _port;
  UsbDevice? _device;

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
        setTerminalText("Disconnected");
      });
      return true;
    }

    _port = await device.create();
    if (await (_port!.open()) != true) {
      setState(() {
        setTerminalText("Failed to open port");
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
      setTerminalText("Connected");
    });
    return true;
  }

  /// 타임 스탬프
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

  void setTerminalText(String data) {
    TerminalText = (TerminalText == null
        ? ""
        : "$TerminalText" + "${getDateToString()} : " + "$data\n");
  }

  void _getPorts() async {
    _ports = [];
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (!devices.contains(_device)) {
      _openPort(null);
    }

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

    Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {});
    });
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
          IconButton(onPressed: () {}, icon: Icon(Icons.dashboard_outlined)),
        ],
      ),
      drawer: Container(
        width: MediaQuery.of(context).size.width * 0.15,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: MyApp.my_darkblue,
                ),
                child: Icon(Icons.usb),
              ),
              ListTile(
                title: const Icon(Icons.list_alt_rounded),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DevicesPage()),
                  );
                },
              ),
              ListTile(
                title: const Icon(Icons.shop_outlined),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AdPaymentPage()),
                  );
                },
              ),
              ListTile(
                title: const Icon(Icons.settings),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingPage()),
                  );
                },
              ),
              ListTile(
                title: const Icon(Icons.info_outline_rounded),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InfoPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      backgroundColor: MyApp.my_darkblue,
      body: Column(
        children: [
          Expanded(
            flex: 11,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border.all(color: MyApp.my_white),
                  borderRadius: BorderRadius.circular(8.0)),
              child: Scrollbar(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Text(
                    (TerminalText == null) ? "" : "$TerminalText",
                    style: TextStyle(color: MyApp.my_white),
                  ),
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
                      labelStyle: TextStyle(color: MyApp.my_red),
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
                    style: TextStyle(color: MyApp.my_white),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: Icon(Icons.send_rounded),
                    onPressed: _port == null
                        ? () {
                            print("port is null");
                          }
                        : () async {
                            if (_port == null) {
                              print("port until null");
                              return;
                            }
                            print("send data");
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
          AdmodBar(context),
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
