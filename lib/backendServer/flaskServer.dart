import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

class FlaskServer {
  static const platform = MethodChannel('chaquopy');

  Future<String> startPythonServer() async {
    try {
      await platform.invokeMethod('start_server');
      return "Serwer Flask został uruchomiony pomyślnie";
    } catch (e) {
      return "Błąd uruchamiania serwera Flask: $e";
    }
  }

  Future<Map<String, dynamic>> sendImageToServer(File imageFile) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://127.0.0.1:5666/process'),
    );
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      contentType: MediaType('image', 'jpeg'),
    ));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);
        return jsonResponse;
      } else {
        return {
          'error': 'Upload failed',
          'statusCode': response.statusCode,
          'message': await response.stream.bytesToString(),
        };
      }
    } catch (e) {
      return {
        'error': 'Exception occurred',
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> sendAnalysisToServer(
      Map<String, dynamic> petriNetJson) async {
    final uri = Uri.parse('http://127.0.0.1:5666/analyze');

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(petriNetJson),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse;
      } else {
        return {
          'error': 'Analysis failed',
          'statusCode': response.statusCode,
          'message': response.body,
        };
      }
    } catch (e) {
      return {
        'error': 'Exception occurred',
        'message': e.toString(),
      };
    }
  }
}
