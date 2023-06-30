import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/state/state.dart';
import '../../main.dart';

class ReadFile extends StatelessWidget {
  const ReadFile({Key? key, required this.device, required this.filename})
      : super(key: key);

  final BluetoothDevice device;
  final String filename;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(device.name ?? "Unknow"),
          actions: <Widget>[
            Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const Home()),
                        (route) => false);
                  },
                  child: Icon(
                    Icons.bluetooth_connected,
                    color: appState.connexion.isConnected == true
                        ? Colors.green
                        : Colors.grey,
                  ),
                )),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(Icons.description_rounded),
              title: Text(
                filename,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
                child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
              child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: SelectableText(appState.fileContent)),
            ))
          ],
        ),
      ),
    );
  }
}
