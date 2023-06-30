import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';

import '../../app/state/state.dart';
import 'device.dart';

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.purple.shade500,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.bluetooth_disabled,
                size: 200.0,
                color: Colors.white54,
              ),
              Text(
                'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
                style: Theme.of(context)
                    .primaryTextTheme
                    .titleSmall
                    ?.copyWith(color: Colors.white),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple),
                child: const Text('TURN ON'),
                onPressed: () =>
                    FlutterBluetoothSerial.instance.requestEnable(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatefulWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

  @override
  State<FindDevicesScreen> createState() => _FindDevicesScreenState();
}

class _FindDevicesScreenState extends State<FindDevicesScreen> {
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;

  List<BluetoothDevice> _devicesList = [];
  late BluetoothConnection connexion;

  @override
  void initState() {
    super.initState();
    bluetoothConnectionState();
  }

  @override
  void dispose() {
    connexion.close();
    super.dispose();
  }

  Future<void> bluetoothConnectionState() async {
    List<BluetoothDevice> devices = [];
    // To get the list of paired devices
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Paired Devices'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.bluetooth_disabled, color: Colors.grey),
                  const CustomSwitch(),
                  const Icon(Icons.bluetooth_connected, color: Colors.green),
                ],
              ),
            )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () {
            return bluetoothConnectionState();
          },
          child: ListView(children: [
            Column(children: [
              Column(
                children: _devicesList
                    .map((e) => ListTile(
                        title: Text(e.name ?? "Unknow"),
                        subtitle: Text(e.address),
                        trailing: ElevatedButton(
                          child: e.isConnected
                              ? const Text('Open')
                              : const Text("Connect"),
                          onPressed: () {
                            if (!e.isConnected) {
                              try {
                                BluetoothConnection.toAddress(e.address)
                                    .then((val) {
                                  connexion = val;
                                  appState.setConnexion(connexion);
                                  appState.listenForIncoming();
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) =>
                                              DeviceScreen(device: e)))
                                      .then((value) {
                                    bluetoothConnectionState();
                                  });
                                });
                              } catch (e) {
                                //
                              }
                            } else {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) =>
                                          DeviceScreen(device: e)))
                                  .then((value) {
                                bluetoothConnectionState();
                              });
                            }
                          },
                        )))
                    .toList(),
              )
            ]),
          ]),
        ),
      ),
    );
  }
}

class CustomSwitch extends StatefulWidget {
  const CustomSwitch({super.key});

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  bool active = true;

  @override
  Widget build(BuildContext context) {
    return Switch(
      activeColor: Colors.green,
      value: active,
      onChanged: (value) {
        setState(() {
          active = value;
        });
        FlutterBluetoothSerial.instance.requestDisable();
      },
    );
  }
}
