import 'package:flutter/material.dart';
import 'package:petri_net_front/data/models/petriNet.dart';
import 'package:petri_net_front/UI/utils/petriNetUtils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petri_net_front/state/providers/petriNetState.dart';
import 'package:widget_arrows/arrows.dart';

class PetriNetElementAdder {
  PetriNetElementAdder({
    required this.transformationController,
    required this.petriNetState,
  });

  final TransformationController transformationController;
  final PetriNet petriNetState;
  dynamic selectedElement;
  dynamic startElement; // Pierwszy wybrany element (stan/tranzycja)
  dynamic endElement; // Drugi wybrany element (stan/tranzycja)

  void addElement(TapDownDetails details, WidgetRef ref) {
    if (selectedElement == null) return;

    final Offset correctedPosition = PetriNetUtils.getCorrectedPosition(
        details.localPosition, transformationController.value);
    if (selectedElement is States) {
      final newState = States(center: correctedPosition, tokens: 0);
      ref.read(petriNetProvider.notifier).addState(newState);
      print("🟡 Dodano stan na pozycji: $correctedPosition");
    } else if (selectedElement is Transition) {
      final newTransitionPositionStart =
          Offset(correctedPosition.dx, correctedPosition.dy + 35);
      final newTransitionPositionEnd =
          Offset(correctedPosition.dx, correctedPosition.dy - 35);
      final newTransition = Transition(
          start: newTransitionPositionStart, end: newTransitionPositionEnd);
      ref.read(petriNetProvider.notifier).addTransition(newTransition);
      print(
          "🟨 Dodano tranzycję na pozycji: $newTransitionPositionStart, $newTransitionPositionEnd");
    } else if (selectedElement is Arrow) {
      handleArcSelection(scenePosition, ref);
      print("➡ Tryb dodawania łuku. Wybierz stan i tranzycję.");
    }

    selectedElement = null; // Resetujemy po dodaniu
  }

  void handleArcSelection(Offset scenePosition, WidgetRef ref) {
    if (startElement == null) {
      // 🔥 Wybieramy pierwszy element (skąd wychodzi łuk)
      startElement = PetriNetUtils.detectState(scenePosition, petriNetState) ??
          PetriNetUtils.detectTransition(scenePosition, petriNetState);

      if (startElement != null) {
        print("✅ Wybrano pierwszy element: ${startElement.label}");
        print("➡ Wybierz element, do którego ma prowadzić łuk.");
      } else {
        print("❌ Kliknięto w pustą przestrzeń. Wybierz stan lub tranzycję.");
      }
    } else if (endElement == null) {
      // 🔥 Wybieramy drugi element (gdzie łuk ma dochodzić)
      endElement = PetriNetUtils.detectState(scenePosition, petriNetState) ??
          PetriNetUtils.detectTransition(scenePosition, petriNetState);

      if (endElement != null) {
        print("✅ Wybrano drugi element: ${endElement.label}");
        createArc(ref);
      } else {
        print("❌ Kliknięto w pustą przestrzeń. Wybierz stan lub tranzycję.");
      }
    }
  }

  void createArc(WidgetRef ref) {
    if (startElement != null && endElement != null) {
      final newArc = Arc(
        start: startElement.center, // 🔥 Pobieramy pozycję startową
        end: endElement.center, // 🔥 Pobieramy pozycję końcową
      );

      print("➡ Dodano łuk od ${startElement.label} do ${endElement.label}");

      // Resetujemy wybór po dodaniu łuku
      startElement = null;
      endElement = null;
    }
  }
}
