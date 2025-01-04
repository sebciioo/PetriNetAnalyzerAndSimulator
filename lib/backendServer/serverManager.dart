import 'package:petri_net_front/backendServer/flaskServer.dart';

class ServerManager {
  final flaskServer = FlaskServer();

  Future<void> initializeServer() async {
    await flaskServer.startPythonServer();
    //await flaskServer.testServerConnection();
    //await flaskServer.testServerConnection2();
    //await flaskServer.testPostRequest();
    await flaskServer.sendImageRequest('data/example_image18.jpg');
  }
}
