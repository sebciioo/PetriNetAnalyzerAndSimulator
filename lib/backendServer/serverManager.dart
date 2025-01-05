import 'package:petri_net_front/backendServer/flaskServer.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/petriNet.dart';

class ServerManager {
  final flaskServer = FlaskServer();

  Future<void> initializeServer() async {
    await flaskServer.startPythonServer();
    //await flaskServer.testServerConnection();
    //await flaskServer.testServerConnection2();
    //await flaskServer.testPostRequest();
    //await flaskServer.sendImageRequest('data/example_image18.jpg');
  }

  Future<PetriNet?> sendImageFromPhoneToServer(File imageFile) async {
    final PetriNet? jsonResponse =
        await flaskServer.sendImageToServer(imageFile);
    return jsonResponse;
  }
}
