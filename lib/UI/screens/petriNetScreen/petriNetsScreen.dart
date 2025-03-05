import 'package:flutter/material.dart';
import 'package:petri_net_front/UI/screens/petriNetScreen/models/PetriNetElementMover.dart';
import 'package:petri_net_front/UI/screens/petriNetScreen/models/PetriNetElementRemover.dart';
import 'package:petri_net_front/UI/screens/petriNetScreen/widget/addElementDialog.dart';
import 'package:petri_net_front/UI/screens/petriNetScreen/widget/addSubtractTokensToState.dart';
import 'package:petri_net_front/data/models/petriNet.dart';
import 'package:petri_net_front/UI/screens/petriNetScreen/widget/featuresTile.dart';
import 'package:petri_net_front/UI/screens/petriNetScreen/widget/managementOption.dart';
import 'package:petri_net_front/UI/screens/petriNetScreen/widget/petriNetPainter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petri_net_front/state/providers/adderState.dart';
import 'package:petri_net_front/state/providers/modeState.dart';
import 'package:petri_net_front/state/providers/transformationState.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:petri_net_front/data/models/mode.dart';
import 'package:petri_net_front/state/providers/petriNetState.dart';

class PetriNetScreen extends ConsumerWidget {
  const PetriNetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petriNetState = ref.watch(petriNetProvider);
    final modeState = ref.watch(modeProvider);
    final transformationController =
        ref.watch(transformationControllerProvider);

    print(petriNetState!.states.length);
    final mover = PetriNetElementMover(
      transformationController: transformationController,
      petriNetState: petriNetState!,
    );
    final adder = ref.watch(petriNetAdderProvider);
    if (modeState.editModeType == EditModeType.addElements &&
        adder!.selectedElement == null) {
      Future.delayed(Duration.zero, () {
        showAddElementDialog(context, adder, ref);
      });
    }

    void activateTransition(Transition transition, bool isActive) {
      if (isActive) {
        for (final arc in transition.incomingArcs) {
          final relatedStates =
              petriNetState!.states.where((s) => s.outgoingArcs.contains(arc));
          for (final state in relatedStates) {
            if (state.tokens > 0) {
              ref.read(petriNetProvider.notifier).removeToken(state);
              break;
            }
          }
        }
        for (final arc in transition.outgoingArcs) {
          final relatedStates =
              petriNetState!.states.where((s) => s.incomingArcs.contains(arc));
          for (final state in relatedStates) {
            ref.read(petriNetProvider.notifier).addToken(state);
          }
        }
      }
    }

    void onTapEditingButton() {
      ref.read(modeProvider.notifier).setEditingMode();
    }

    void onTapSimulationButton() {
      ref.read(modeProvider.notifier).setSimulationMode();
    }

    // Funkcja generująca dynamiczne przyciski
    List<Widget> _buildTransitionButtons(WidgetRef ref) {
      return petriNetState!.transitions.map((transition) {
        final Offset rawPosition = Offset(
          (transition.start.dx + transition.end.dx) / 2,
          (transition.start.dy + transition.end.dy) / 2,
        );

        const double buttonSize = 50.0;

        // Sprawdzamy, czy tranzycja jest aktywna
        final isActive = transition.incomingArcs.every((arc) {
          final relatedStates =
              petriNetState.states.where((s) => s.outgoingArcs.contains(arc));
          return relatedStates.any((state) => state.tokens >= 1);
        });

        if (!isActive) return const SizedBox.shrink();

        return Positioned(
          top: rawPosition.dy - (buttonSize / 2),
          left: rawPosition.dx - (buttonSize / 2),
          child: DeferPointer(
            child: GestureDetector(
              onTap: () {
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
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (details) {
                  if (modeState.editModeType == EditModeType.removeElements) {
                    final remover = PetriNetElementRemover(
                      transformationController: transformationController,
                      petriNetState: petriNetState!,
                    );
                    final clickedElement = remover.handleTap(details);

                    if (clickedElement is States) {
                      print('❌ Usunięto stan');
                      ref
                          .read(petriNetProvider.notifier)
                          .removeState(clickedElement);
                    } else if (clickedElement is Transition) {
                      print('❌ Usunięto tranzycję');
                      ref
                          .read(petriNetProvider.notifier)
                          .removeTransition(clickedElement);
                    } else if (clickedElement is Arc) {
                      print('❌ Usunięto łuk');
                      ref
                          .read(petriNetProvider.notifier)
                          .removeArc(clickedElement);
                    }
                  }
                  if (modeState.editModeType == EditModeType.addElements) {
                    ref.read(petriNetAdderProvider.notifier).addElement(details,
                        transformationController.value, petriNetState, ref);
                  }
                },
                child: InteractiveViewer(
                  clipBehavior: Clip.none,
                  boundaryMargin: const EdgeInsets.all(2000.0),
                  minScale: 0.5,
                  transformationController: transformationController,
                  maxScale: 3.0,
                  panEnabled: !ref.watch(draggingStateProvider),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Tło i diagram
                      Container(
                        width: 2000,
                        height: 2000,
                        color: Colors.grey[200],
                        child: CustomPaint(
                          painter: PetriNetPainter(petriNet: petriNetState),
                        ),
                      ),

                      if (modeState.simulationMode == true)
                        ..._buildTransitionButtons(ref),
                      if (modeState.editModeType == EditModeType.addTokens)
                        const AddSubtractTokensToState(),
                    ],
                  ),
                  onInteractionStart: (ScaleStartDetails details) {
                    if (details.pointerCount == 1 &&
                        modeState.editModeType == EditModeType.moveElements) {
                      // Konwersja ScaleStartDetails na DragStartDetails
                      final dragStartDetails = DragStartDetails(
                        globalPosition: details.focalPoint,
                        localPosition: details.localFocalPoint,
                      );
                      mover.handleDragStart(dragStartDetails, ref);
                    }
                  },
                  onInteractionUpdate: (ScaleUpdateDetails details) {
                    if (details.pointerCount == 1 &&
                        details.scale == 1.0 &&
                        modeState.editModeType == EditModeType.moveElements) {
                      // Konwersja ScaleUpdateDetails na DragUpdateDetails
                      final dragUpdateDetails = DragUpdateDetails(
                        globalPosition: details.focalPoint,
                        delta: details.focalPointDelta,
                      );
                      mover.handleDragUpdate(dragUpdateDetails, ref);
                    }
                  },
                  onInteractionEnd: (ScaleEndDetails details) {
                    if (modeState.editModeType == EditModeType.moveElements) {
                      mover.handleDragEnd(ref);
                    }
                  },
                ),
              ),
            ),
            if (modeState.editModeType == EditModeType.removeElements ||
                modeState.editModeType == EditModeType.moveElements ||
                (modeState.editModeType == EditModeType.addElements &&
                    (adder?.selectionMessage.isNotEmpty == true)))
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Text(
                        modeState.editModeType == EditModeType.removeElements
                            ? "Kliknij na element, który chcesz usunąć"
                            : modeState.editModeType ==
                                    EditModeType.moveElements
                                ? "Przesuń wybrany element"
                                : adder!.selectionMessage,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
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
                              ManagementOption(petriNet: petriNetState!),
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
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center, // Wyśrodkowanie

                          children: [
                            Text(
                              modeState.simulationMode
                                  ? "Tryb symulacji"
                                  : "Tryb edycji",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.scrim,
                              ),
                            ),
                            SizedBox(width: 5), // Odstęp między tekstem a ikoną
                            Icon(
                              modeState.simulationMode
                                  ? Icons.play_circle_fill
                                  : Icons.edit, // Zmiana ikony
                              color: Colors.black,
                              size: 22, // Rozmiar ikony
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Switch(
                          value: modeState.simulationMode,
                          activeColor: Colors.white, // Kolor kółka
                          activeTrackColor:
                              Color(0xFF0077B6), // Kolor toru włączonego
                          inactiveTrackColor:
                              Colors.grey[400], // Kolor toru wyłączonego
                          onChanged: (bool value) {
                            if (value) {
                              onTapSimulationButton();
                            } else {
                              onTapEditingButton();
                            }
                          },
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
