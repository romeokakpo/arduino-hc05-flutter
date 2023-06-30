import 'package:control_app/app/state/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'ui/screens/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  [Permission.bluetooth, Permission.bluetoothScan, Permission.bluetoothConnect]
      .request()
      .then((status) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => AppState(),
        child: MaterialApp(
          title: 'Bluetooth',
          theme: ThemeData(
            primarySwatch: Colors.purple,
          ),
          home: const Home(),
        ));
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  BluetoothState _bState = BluetoothState.UNKNOWN;

  @override
  void initState() {
    super.initState();
    FlutterBluetoothSerial.instance.onStateChanged().listen((event) {
      setState(() {
        _bState = event;
      });
    });
    checkConnected();
  }

  void checkConnected() async {
    if (await FlutterBluetoothSerial.instance.isEnabled == true) {
      setState(() {
        _bState = BluetoothState.STATE_ON;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bState == BluetoothState.STATE_ON) {
      return const FindDevicesScreen();
    }
    return BluetoothOffScreen(state: _bState);
  }
}
