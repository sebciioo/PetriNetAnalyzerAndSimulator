import 'package:flutter/material.dart';
import 'package:petri_net_front/UI/screens/imagePickerScreen/imagePickerScreen.dart';
import 'package:petri_net_front/UI/utils/responsive_constants.dart';

class homeScreen extends StatelessWidget {
  const homeScreen({super.key});

  void goToUploadFile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => const ImagePickerScreen()),
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
                        onPressed: () {},
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
