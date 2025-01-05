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

  Future<void> startPythonServer() async {
    try {
      final result = await platform.invokeMethod('start_server');
      debugPrint('Serwer Flask został uruchomiony: $result');
    } catch (e) {
      debugPrint('Błąd uruchamiania serwera Flask: $e');
    }
  }

  Future<void> testServerConnection() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.16:5666'));
      if (response.statusCode == 200) {
        debugPrint('Połączenie z serwerem Flask działa: ${response.body}');
      } else {
        debugPrint('Błąd połączenia: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Nie można połączyć się z serwerem Flask: $e');
    }
  }

  Future<void> testServerConnection2() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.16:5666'));
      if (response.statusCode == 200) {
        debugPrint('Połączenie z serwerem Flask działa: ${response.body}');
      } else {
        debugPrint('Błąd połączenia: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Nie można połączyć się z serwerem Flask: $e');
    }
  }

  Future<void> testPostRequest() async {
    final url = Uri.parse('http://10.0.2.16:5666/test_post');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({"name": "John Doe", "age": 25});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print('Odpowiedź serwera: ${response.body}');
      } else {
        print('Błąd: ${response.statusCode}');
      }
    } catch (e) {
      print('Błąd podczas wysyłania żądania POST: $e');
    }
  }

  Future<void> sendImageRequest(String imagePath) async {
    final String url = 'http://10.0.2.16:5666/process'; // Adres serwera Flask

    try {
      // Tworzenie URI z parametrem GET
      final Uri uri = Uri.parse(url).replace(queryParameters: {
        'image': imagePath,
      });

      // Wysyłanie żądania GET
      final response = await http.get(uri);

      // Sprawdzanie odpowiedzi serwera
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Odpowiedź serwera: $data');
      } else {
        print('Błąd serwera: ${response.statusCode}');
      }
    } catch (e) {
      print('Błąd połączenia: $e');
    }
  }

  Future<PetriNet?> sendImageToServer(File imageFile) async {
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
        return PetriNet.fromJson(jsonResponse);
      } else {
        print('Upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Błąd podczas wysyłania obrazu: $e');
      return null;
    }
  }
}
