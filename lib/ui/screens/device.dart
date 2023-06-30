import 'package:control_app/main.dart';
import 'package:control_app/ui/screens/list.dart';
import 'package:control_app/ui/screens/write.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/state/state.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

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
                      try {
                        appState.disposeConnexion();
                        Navigator.pop(context);
                      } catch (e) {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const Home()),
                            (route) => false);
                      }
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
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => WriteToFile(device: device)));
                    },
                    child: const Text("Ecrire un fichier")),
                // CustomButton(
                //     onPressed: () {
                //       Navigator.of(context).push(MaterialPageRoute(
                //           builder: (context) => WriteToFile(device: device)));
                //     },
                //     child: const Text("Modifier un fichier")),
                CustomButton(
                    onPressed: () {
                      appState.changeLastCommand("ls");
                      appState.sendMessage("ls");
                      appState.fileList = [
                        ["loading", "0"]
                      ];

                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ListFiles(device: device)));
                    },
                    child: const Text("Lire un fichier"))
              ],
            ),
          )),
    );
  }
}

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, required this.onPressed, required this.child});
  final void Function() onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(fixedSize: const Size(150, 10)),
      child: child,
    );
  }
}
