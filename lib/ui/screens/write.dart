import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/state/state.dart';
import '../../main.dart';

class WriteToFile extends StatefulWidget {
  const WriteToFile({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  State<WriteToFile> createState() => _WriteToFileState();
}

class _WriteToFileState extends State<WriteToFile> {
  TextEditingController textarea = TextEditingController();
  TextEditingController input = TextEditingController();
  String limite = "#\$#";

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.device.name ?? "Unknow"),
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
        body: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: input,
                  decoration: InputDecoration(
                      hintText: "Nom du fichier",
                      border: const OutlineInputBorder(
                          borderSide: BorderSide(width: 1)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1, color: Colors.purple.shade300))),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0, bottom: 8),
                  child: TextField(
                    controller: textarea,
                    keyboardType: TextInputType.multiline,
                    maxLines: 15,
                    decoration: InputDecoration(
                        hintText: "Contenu du fichier",
                        border: const OutlineInputBorder(
                            borderSide: BorderSide(width: 1)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1, color: Colors.purple.shade300))),
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      appState.sendMessage(
                          "wr$limite${input.text.trim()}$limite${textarea.text}");
                      input.clear();
                      textarea.clear();
                      FocusScope.of(context).requestFocus(FocusNode());
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Fichier sauvegardé"),
                      ));
                    },
                    child: const Text("Sauvegarder"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
