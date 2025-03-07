import 'package:petri_net_front/backendServer/flaskServer.dart';
import 'dart:async';
import 'dart:io';

class ServerManager {
  final flaskServer = FlaskServer();

  Future<String> initializeServer() async {
    final String responseServer = await flaskServer.startPythonServer();
    return responseServer;
  }

  Future<Map<String, dynamic>> sendImageFromPhoneToServer(
      File imageFile) async {
    final jsonResponse = await flaskServer.sendImageToServer(imageFile);
    return jsonResponse;
  }

  Future<Map<String, dynamic>> sendAnalysisToServer(
      Map<String, dynamic> petriNetJson) async {
    final jsonResponse = await flaskServer.sendAnalysisToServer(petriNetJson);
    return jsonResponse;
  }
}
