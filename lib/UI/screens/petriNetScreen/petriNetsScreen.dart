import 'package:flutter/material.dart';
import 'package:petri_net_front/UI/screens/imagePickerScreen/widget/customElevatedButton.dart';
import 'package:petri_net_front/UI/screens/petriNetScreen/models/petriNet.dart';
import 'package:petri_net_front/UI/screens/petriNetScreen/widget/featuresTile.dart';
import 'package:petri_net_front/UI/screens/petriNetScreen/widget/managementOption.dart';
import 'package:petri_net_front/UI/screens/petriNetScreen/widget/petriNetPainter.dart';
import 'package:petri_net_front/UI/utils/responsive_constants.dart';

class PetriNetScreen extends StatefulWidget {
  const PetriNetScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _PetriNetScreen();
  }
}

class _PetriNetScreen extends State<PetriNetScreen> {
  final PetriNet petriNet = PetriNet();
  bool? editingMode;
  bool? simulationMode;

  @override
  void initState() {
    super.initState();
    editingMode = false;
    simulationMode = true;
    // Tworzenie przykładowej sieci Petriego
    final state1 = States(center: Offset(100, 200), label: 'S1', tokens: 101);
    final state2 = States(center: Offset(400, 200), label: 'S2', tokens: 3);
    final state3 = States(center: Offset(150, 450), label: 'S3', tokens: 2);
    final transition1 = Transition(
      start: Offset(200, 150),
      end: Offset(200, 220),
      label: 'T1',
    );
    final transition2 = Transition(
      start: Offset(100, 320),
      end: Offset(180, 350),
      label: 'T2',
    );

    // Tworzenie łuków
    final arc1 = Arc(
      start: state1.center,
      end: transition1.start,
      label: 'A1',
      arrowPosition: 'end',
    );
    final arc2 = Arc(
      start: transition1.end,
      end: state2.center,
      label: 'A2',
      arrowPosition: 'end',
    );
    final arc3 = Arc(
      start: state1.center,
      end: transition2.start,
      label: 'A3',
      arrowPosition: 'end',
    );
    final arc4 = Arc(
      start: transition2.end,
      end: state3.center,
      label: 'A4',
      arrowPosition: 'end',
    );

    // Łączenie elementów w modelu
    state1.outgoingArcs.add(arc1);
    state1.outgoingArcs.add(arc3);
    transition1.incomingArcs.add(arc1);
    transition1.outgoingArcs.add(arc2);
    transition2.incomingArcs.add(arc3);
    transition2.outgoingArcs.add(arc4);
    state2.incomingArcs.add(arc2);
    state3.incomingArcs.add(arc4);

    // Tworzenie sieci Petriego
    petriNet.states.addAll([state1, state2, state3]);
    petriNet.transitions.addAll([transition1, transition2]);
    petriNet.arcs.addAll([arc1, arc2, arc3, arc4]);
  }

  void activateTransition(Transition transition) {
    // Sprawdzanie, czy tranzycja jest aktywna
    final isActive = transition.incomingArcs.every((arc) {
      final state = petriNet.states.firstWhere((s) => s.center == arc.start);
      return state.tokens >= 1; // Zakładamy wagę łuku równą 1
    });

    if (isActive) {
      setState(() {
        // Usuwanie tokenów z powiązanych stanów
        for (final arc in transition.incomingArcs) {
          final state =
              petriNet.states.firstWhere((s) => s.center == arc.start);
          state.tokens--;
        }

        // Dodawanie tokenów do powiązanych stanów
        for (final arc in transition.outgoingArcs) {
          final state = petriNet.states.firstWhere((s) => s.center == arc.end);
          state.tokens++;
        }
      });
    }
  }

  void onTapEditingButton() {
    setState(() {
      editingMode = true;
      simulationMode = false;
    });
  }

  void onTapSimulationButton() {
    setState(() {
      editingMode = false;
      simulationMode = true;
    });
  }

  List<Widget> _buildTransitionButtons() {
    return petriNet.transitions.map((transition) {
      final centerX = (transition.start.dx + transition.end.dx) / 2;
      final centerY = (transition.start.dy + transition.end.dy) / 2;
      const double transitionHeight = 60.0;
      double top = 0;
      double left = 0;
      if ((transition.end.dx - transition.start.dx).abs() >
          (transition.end.dy - transition.start.dy).abs()) {
        // Pozioma tranzycja
        top = centerY - 30;
        left = centerX + 20;
      } else {
        // Pionowa tranzycja
        top = centerY - 60;
        left = centerX - 5;
      }

      // Sprawdzanie, czy tranzycja jest aktywna
      final isActive = transition.incomingArcs.every((arc) {
        final state = petriNet.states.firstWhere((s) => s.center == arc.start);
        return state.tokens >= 1;
      });

      if (!isActive) return const SizedBox.shrink();
      return Positioned(
        top: top,
        left: left,
        child: IconButton(
          icon: const Icon(Icons.play_circle_outline_sharp), // Ikona przycisku
          iconSize: 50, // Rozmiar ikony
          color: Color(0xFF00bcd4), // Kolor ikony
          onPressed: () => activateTransition(transition), // Akcja kliknięcia
          splashRadius: 20, // Promień efektu kliknięcia
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    print(editingMode);
    print(simulationMode);
    return Scaffold(
      appBar: AppBar(
        title: const Text('PetriMind',
            style: TextStyle(
              fontFamily: 'htr',
              color: Colors.white, // Kolor tekstu
              fontSize: 40,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.0,
              shadows: [
                Shadow(
                  offset: Offset(1.5, 1.5),
                  color: Colors.black,
                ),
                Shadow(
                  offset: Offset(1.5, 1.5),
                  color: Colors.black,
                ),
                Shadow(
                  offset: Offset(1.5, 1.5),
                  color: Colors.black,
                ),
                Shadow(
                  offset: Offset(2, 1.5),
                  color: Colors.black,
                ),
              ],
            )),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 25,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(2000.0),
              minScale: 0.5,
              maxScale: 3.0,
              child: Stack(
                children: [
                  Container(
                    width: 2000,
                    height: 2000,
                    color: Colors.grey[200],
                    child: CustomPaint(
                      painter: PetriNetPainter(petriNet: petriNet),
                    ),
                  ),
                  if (simulationMode == true) ..._buildTransitionButtons(),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
                stops: const [0.0, 0.5],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left section
                Expanded(
                  flex: 1,
                  child: RawScrollbar(
                    thumbColor: Colors.white,
                    thumbVisibility: true,
                    thickness: 5.0,
                    radius: Radius.circular(8),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (simulationMode == true) ...[
                            const FeaturesTile(
                              title: "Cechy behawioralne",
                              items: [
                                "Analiza przepustowości",
                                "Sprawdzenie blokowania",
                                "Analiza miejsc nadmiarowych",
                              ],
                            ),
                            const FeaturesTile(
                              title: "Cechy strukturalne",
                              items: [
                                "Analiza ścieżek",
                                "Analiza połączeń",
                              ],
                            ),
                          ] else
                            ManagementOption(petriNet: petriNet),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                // Right section
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: double
                            .infinity, // Stretches the button horizontally
                        child: CustomElevatedButton(
                          label: "Tryb symulacji",
                          onPressed: onTapSimulationButton,
                          backgroundColor: simulationMode!
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.white,
                          textColor: simulationMode!
                              ? Colors.white
                              : Theme.of(context).colorScheme.inverseSurface,
                          fontMin: 15,
                          fontMax: 20,
                        ),
                      ),
                      const SizedBox(height: 16), // Spacing between the buttons
                      SizedBox(
                        width: double
                            .infinity, // Stretches the button horizontally
                        child: CustomElevatedButton(
                          label: "Tryb edycji",
                          onPressed: onTapEditingButton,
                          backgroundColor: editingMode!
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.white,
                          textColor: editingMode!
                              ? Colors.white
                              : Theme.of(context).colorScheme.inverseSurface,
                          fontMin: 15,
                          fontMax: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
