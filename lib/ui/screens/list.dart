import 'package:control_app/ui/screens/read.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/state/state.dart';
import '../../main.dart';

String formatSize(int sizeInBytes) {
  if (sizeInBytes < 1024) {
    return "$sizeInBytes B"; // Taille en octets
  } else if (sizeInBytes < 1024 * 1024) {
    double sizeInKB = sizeInBytes / 1024;
    return "${sizeInKB.toStringAsFixed(2)} KB"; // Taille en kilo-octets
  } else if (sizeInBytes < 1024 * 1024 * 1024) {
    double sizeInMB = sizeInBytes / (1024 * 1024);
    return "${sizeInMB.toStringAsFixed(2)} MB"; // Taille en méga-octets
  } else {
    double sizeInGB = sizeInBytes / (1024 * 1024 * 1024);
    return "${sizeInGB.toStringAsFixed(2)} GB"; // Taille en giga-octets
  }
}

class CustomList extends StatelessWidget {
  const CustomList(
      {super.key,
      required this.onTap,
      required this.onLongPress,
      required this.filename,
      required this.size});

  final void Function() onTap;
  final void Function() onLongPress;
  final String filename;
  final String size;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: const VisualDensity(vertical: -4),
      leading: const Icon(Icons.description_rounded),
      title: Text(filename),
      subtitle: Text(size),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}

class ListFiles extends StatelessWidget {
  const ListFiles({Key? key, required this.device}) : super(key: key);

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
        body: Center(
          child: Column(children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Liste des fichiers",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            if (appState.fileList.isNotEmpty)
              Expanded(
                child: ListView(
                    children: ListTile.divideTiles(
                        context: context,
                        tiles: appState.fileList.map(
                          (e) => CustomList(
                            filename: e[0],
                            size: formatSize(int.parse(e[1])),
                            onTap: () {
                              appState.changeLastCommand("rd");
                              appState.sendMessage("rd|${e[0]}");
                              appState.fileContent = "Loading...";
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ReadFile(
                                        device: device,
                                        filename: e[0],
                                      )));
                            },
                            onLongPress: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Wrap(
                                    children: [
                                      ListTile(
                                        visualDensity:
                                            const VisualDensity(vertical: -4),
                                        title: Text('Filename: ${e[0]}'),
                                      ),
                                      ListTile(
                                        visualDensity:
                                            const VisualDensity(vertical: -4),
                                        title: Text(
                                            'Size: ${formatSize(int.parse(e[1]))}'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        )).toList()),
              )
            else
              const Expanded(
                  child: Center(
                child: Text(
                  "Pas de fichiers",
                  style: TextStyle(color: Colors.grey),
                ),
              ))
          ]),
        ),
      ),
    );
  }
}
