import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petri_net_front/UI/screens/imagePickerScreen/imagePickerScreen.dart';
import 'package:petri_net_front/UI/utils/responsive_constants.dart';
import 'package:petri_net_front/backendServer/serverManager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.serverManager});

  final ServerManager serverManager;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String serverResponse = '';
  @override
  void initState() {
    super.initState();
    startServer();
  }

  void startServer() async {
    final response = await widget.serverManager.initializeServer();
    setState(() {
      serverResponse = response;
    });
  }

  void goToUploadFile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (ctx) => ImagePickerScreen(
                serverManager: widget.serverManager,
              )),
    );
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
              Text(
                "PetriMind",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inverseSurface,
                    fontSize: screenHeight * 0.13,
                    fontFamily: 'htr',
                    fontWeight: FontWeight.w500),
              ),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0),
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
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  child: Text(""), // Pusty tekst jako placeholder
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
