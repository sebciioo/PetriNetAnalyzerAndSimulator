import 'package:flutter/material.dart';
import 'package:petri_net_front/UI/screens/imagePickerScreen/widget/customElevatedButton.dart';
import 'package:petri_net_front/data/models/petriNet.dart';
import 'package:petri_net_front/UI/screens/petriNetScreen/widget/featuresTile.dart';
import 'package:petri_net_front/UI/screens/petriNetScreen/widget/managementOption.dart';
import 'package:petri_net_front/UI/screens/petriNetScreen/widget/petriNetPainter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petri_net_front/state/providers/modeState.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:petri_net_front/state/providers/petriNetState.dart';

class PetriNetScreen extends ConsumerWidget {
  const PetriNetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petriNetState = ref.watch(petriNetProvider);
    final modeState = ref.watch(modeProvider);
    final transformationController = TransformationController();

    void activateTransition(Transition transition, bool isActive) {
      if (isActive) {
        // Usuwanie tokenów z powiązanych stanów
        for (final arc in transition.incomingArcs) {
          final relatedStates =
              petriNetState!.states.where((s) => s.outgoingArcs.contains(arc));
          for (final state in relatedStates) {
            if (state.tokens > 0) {
              state.tokens--;
              break; // Upewnij się, że usuwasz tylko jeden token
            }
          }
        }

        // Dodawanie tokenów do powiązanych stanów
        for (final arc in transition.outgoingArcs) {
          final relatedStates =
              petriNetState!.states.where((s) => s.incomingArcs.contains(arc));
          for (final state in relatedStates) {
            state.tokens++; // Dodawanie tokenu do każdego powiązanego stanu
          }
        }
        ref.read(petriNetProvider.notifier).updateState();
      }
    }

    void onTapEditingButton() {
      ref.read(modeProvider.notifier).setEditingMode();
    }

    void onTapSimulationButton() {
      ref.read(modeProvider.notifier).setSimulationMode();
    }

    // Funkcja generująca dynamiczne przyciski
    List<Widget> _buildTransitionButtons() {
      return petriNetState!.transitions.map((transition) {
        final position = Offset(
          (transition.start.dx + transition.end.dx) / 2,
          (transition.start.dy + transition.end.dy) / 2,
        );

        final transformedPosition = transformationController.toScene(position);

        const double buttonSize = 50.0;

        final isActive = transition.incomingArcs.every((arc) {
          final relatedStates =
              petriNetState.states.where((s) => s.outgoingArcs.contains(arc));
          return relatedStates.any((state) => state.tokens >= 1);
        });

        if (!isActive) return const SizedBox.shrink();

        return Positioned(
          top: transformedPosition.dy - buttonSize / 2,
          left: transformedPosition.dx - buttonSize / 2,
          child: DeferPointer(
            child: GestureDetector(
              onTap: () {
                // Obsługa kliknięcia
                activateTransition(transition, isActive);
              },
              child: Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_circle_outline_sharp,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      }).toList();
    }

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
      body: DeferredPointerHandler(
        child: Column(
          children: [
            Expanded(
              child: InteractiveViewer(
                clipBehavior: Clip.none,
                boundaryMargin: const EdgeInsets.all(2000.0),
                minScale: 0.5,
                maxScale: 3.0,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Tło i diagram
                    Container(
                      width: 2000,
                      height: 2000,
                      color: Colors.grey[200],
                      child: CustomPaint(
                        painter: PetriNetPainter(petriNet: petriNetState!),
                      ),
                    ),
                    // Przyciski na stałych pozycjach w stosunku do diagramu
                    if (modeState.simulationMode == true)
                      ..._buildTransitionButtons(),
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
                            if (modeState.simulationMode == true) ...[
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
                              ManagementOption(petriNet: petriNetState),
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
                            backgroundColor: !modeState.simulationMode
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.white,
                            textColor: !modeState.simulationMode
                                ? Colors.white
                                : Theme.of(context).colorScheme.inverseSurface,
                            fontMin: 15,
                            fontMax: 20,
                          ),
                        ),
                        const SizedBox(
                            height: 16), // Spacing between the buttons
                        SizedBox(
                          width: double
                              .infinity, // Stretches the button horizontally
                          child: CustomElevatedButton(
                            label: "Tryb edycji",
                            onPressed: onTapEditingButton,
                            backgroundColor: !modeState.editingMode
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.white,
                            textColor: !modeState.editingMode
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
      ),
    );
  }
}
