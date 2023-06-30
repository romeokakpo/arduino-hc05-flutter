import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class AppState extends ChangeNotifier {
  AppState();

  late BluetoothConnection connexion;
  String readFromBlue = "";
  String lastCommand = "";
  List<dynamic> fileList = [];
  String fileContent = "";

  void setConnexion(BluetoothConnection conn) {
    connexion = conn;
  }

  void disposeConnexion() {
    connexion.close();
  }

  void sendMessage(String msg) async {
    Uint8List bytes = Uint8List.fromList(utf8.encode(msg));
    connexion.output.add(bytes);
    await connexion.output.allSent;
  }

  void sendLongText(String text) async {
    const int chunkSize = 50;
    int currentPosition = 0;
    Uint8List bytes;
    String chunk;

    while (currentPosition < text.length) {
      if (currentPosition > text.length) {
        chunk = text.substring(currentPosition, currentPosition + chunkSize);
      } else {
        chunk = text.substring(currentPosition, text.length);
      }
      bytes = Uint8List.fromList(utf8.encode(chunk));
      connexion.output.add(bytes);
      await connexion.output.allSent;
      currentPosition += chunkSize;
    }
  }

  void changeLastCommand(String cmd) {
    lastCommand = cmd;
  }

  void setFileContent(String msg) {
    fileContent = msg;
    notifyListeners();
  }

  void setListFile(String strList) {
    if (readFromBlue.isNotEmpty) {
      fileList = [];
      var tabSplit = strList.split("|");
      for (var t in tabSplit) {
        fileList.add(t.split("*"));
      }
    }
    notifyListeners();
  }

  void listenForIncoming() {
    String received = "";
    try {
      connexion.input?.listen((Uint8List data) {
        received = utf8.decode(data);
        readFromBlue += received;
        if (received.endsWith("#")) {
          readFromBlue = readFromBlue.substring(0, readFromBlue.length - 1);
          if (lastCommand == "ls") {
            setListFile(readFromBlue.substring(0, readFromBlue.length - 1));
            lastCommand = "";
          } else if (lastCommand == "rd") {
            setFileContent(readFromBlue);
            lastCommand = "";
          }
          readFromBlue = "";
        }
      }).onDone(() {
        print('Disconnected by remote request');
      });
    } on StateError {
      //
    }
  }
}
