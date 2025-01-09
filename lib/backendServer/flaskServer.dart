import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import '../../data/models/petriNet.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

class FlaskServer {
  static const platform = MethodChannel('chaquopy');

  Future<String> startPythonServer() async {
    try {
      final result = await platform.invokeMethod('start_server');
      debugPrint('Serwer Flask został uruchomiony: $result');
      return "Serwer Flask został uruchomiony pomyślnie";
    } catch (e) {
      debugPrint('Błąd uruchamiania serwera Flask: $e');
      return "Błąd uruchamiania serwera Flask: $e";
    }
  }

  Future<Map<String, dynamic>> sendImageToServer(File imageFile) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.16:5666/process'),
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
        print('Upload successful. Server response: $jsonResponse');
        return jsonResponse;
      } else {
        print('Upload failed with status: ${response.statusCode}');
        return {
          'error': 'Upload failed',
          'statusCode': response.statusCode,
          'message': await response.stream.bytesToString(),
        };
      }
    } catch (e) {
      print('Błąd podczas wysyłania obrazu: $e');
      return {
        'error': 'Exception occurred',
        'message': e.toString(),
      };
    }
  }
}
