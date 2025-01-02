import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:petri_net_front/UI/screens/imagePickerScreen/imagePickerScreen.dart';
import 'package:petri_net_front/UI/utils/responsive_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

Future<void> startPythonServer() async {
  const platform = MethodChannel('chaquopy');
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

/*
Future<void> checkServerHealth() async {
  int retryCount = 0; // Licznik prób połączenia
  const int maxRetries = 5; // Maksymalna liczba prób

  while (true) {
    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:5666/health'))
          .timeout(
              Duration(seconds: 2)); // Ustawienie limitu czasu na 2 sekundy

      if (response.statusCode == 200) {
        print('Serwer działa');
        retryCount = 0; // Reset liczby prób, jeśli serwer odpowiada
      } else {
        print('Serwer nie odpowiada, kod odpowiedzi: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      print('Przekroczono czas oczekiwania na odpowiedź serwera.');
      retryCount++;
    } catch (e) {
      print('Nie można połączyć się z serwerem: $e');
      retryCount++;
    }

    // Sprawdzenie, czy serwer jest zawieszony
    if (retryCount >= maxRetries) {
      print('Serwer nie odpowiada przez $maxRetries kolejne próby.');
      final isServerRunning = await _checkIfServerIsRunning();
      if (isServerRunning) {
        print('Serwer jest uruchomiony, ale nie odpowiada na żądania.');
      } else {
        print('Serwer jest wyłączony lub zawieszony.');
      }
      retryCount = 0; // Reset licznika prób
    }

    await Future.delayed(Duration(seconds: 2)); // Odczekaj przed kolejną próbą
  }
}

Future<bool> _checkIfServerIsRunning() async {
  try {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:5666/health'))
        .timeout(Duration(seconds: 2));
    return response.statusCode == 200;
  } on TimeoutException {
    return false;
  } catch (_) {
    return false;
  }
}
*/
Future<void> checkServerHealth() async {
  try {
    final response = await http
        .get(Uri.parse('http://10.0.2.16:5666/health'))
        .timeout(Duration(seconds: 2));
    if (response.statusCode == 200) {
      print('Serwer działa: ${response.body}');
    } else {
      print('Serwer nie odpowiada: ${response.statusCode}');
    }
  } catch (e) {
    print('Nie można połączyć się z serwerem: $e');
  }
}

class _HomeScreenState extends State<HomeScreen> {
  void goToUploadFile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => const ImagePickerScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.sizeOf(context).width;
    var screenHeight = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.onPrimary
              ],
              stops: const [0.0, 0.3, 0.8],
              begin: const AlignmentDirectional(-1.0, -1.0),
              end: const AlignmentDirectional(1.0, 1.0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //Nazwa
              Text(
                "PetriMind",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inverseSurface,
                    fontSize: screenHeight * 0.13,
                    fontFamily: 'htr',
                    fontWeight: FontWeight.w500),
              ),
              // Logo + nagłówek
              Column(
                children: [
                  CircleAvatar(
                    radius: screenWidth * 0.4,
                    backgroundColor: Colors.black,
                    child: Image.asset(
                      'assets/image/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Zaczynamy!",
                    style: TextStyle(
                      fontSize:
                          MediaQuery.sizeOf(context).width < kBreakpointSmall
                              ? 34.0
                              : 45.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                  ),
                  Text(
                    "Symuluj, analizuj - zrozum sieci Petriego!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Inter',
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                  ),
                ],
              ),
              // Przyciski
              // 3. Przycisk Utwórz konto i Zaloguj się
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => goToUploadFile(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          "Gotowy",
                          style: TextStyle(
                            fontSize: MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall
                                ? 16.0
                                : 28.0,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    // Przycisk Zaloguj się
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await startPythonServer();
                          await checkServerHealth();
                          await testServerConnection2();
                          await testPostRequest();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.secondary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          "Instrukcja",
                          style: TextStyle(
                              fontSize: MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall
                                  ? 16.0
                                  : 28.0,
                              color:
                                  Theme.of(context).colorScheme.inverseSurface),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
