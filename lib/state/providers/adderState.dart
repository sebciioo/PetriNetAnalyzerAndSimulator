import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petri_net_front/UI/screens/petriNetScreen/models/PetriNetElementAdder.dart';
import 'package:petri_net_front/UI/utils/PetriNetUtils.dart';
import 'package:petri_net_front/data/models/petriNet.dart';
import 'package:petri_net_front/state/providers/petriNetState.dart';

const _keepValue = Object();

class PetriNetAdderNotifier extends StateNotifier<PetriNetElementAdder> {
  PetriNetAdderNotifier() : super(PetriNetElementAdder());

  /// 🔥 Resetuje wybór i komunikat
  void resetSelection() {
    state = PetriNetElementAdder(
      startElement: null,
      endElement: null,
      selectedElement: null,
      selectionMessage: "",
    );
  }

  void updateState({
    dynamic selectedElement = _keepValue,
    dynamic startElement = _keepValue,
    dynamic endElement = _keepValue,
    String? selectionMessage,
  }) {
    state = PetriNetElementAdder(
      selectedElement: selectedElement == _keepValue
          ? state.selectedElement
          : selectedElement,
      startElement:
          startElement == _keepValue ? state.startElement : startElement,
      endElement: endElement == _keepValue ? state.endElement : endElement,
      selectionMessage:
          selectionMessage ?? state.selectionMessage, // 🔥 Obsługa `String?`
    );
  }

  void updateSelectedElement(dynamic newElement) {
    if (newElement is Arc) {
      updateState(
          selectedElement: newElement,
          selectionMessage: "Kliknij w pierwszy element");
    } else {
      updateState(
          selectedElement: newElement,
          selectionMessage: "Umieść element na ekranie");
    }
  }

  /// 🔥 Obsługa kliknięcia na ekranie (dodawanie stanu, tranzycji lub łuku)
  void addElement(TapDownDetails details, Matrix4 transformationControllerValue,
      PetriNet petriNetState, WidgetRef ref) {
    if (state.selectedElement == null) return;

    final Offset correctedPosition = PetriNetUtils.getCorrectedPosition(
        details.localPosition, transformationControllerValue);

    if (state.selectedElement is States) {
      final newState = States(center: correctedPosition, tokens: 0);
      ref.read(petriNetProvider.notifier).addState(newState);
      print("🟡 Dodano stan na pozycji: $correctedPosition");
      updateState(selectedElement: null, selectionMessage: '');
    } else if (state.selectedElement is Transition) {
      final newTransitionPositionStart =
          Offset(correctedPosition.dx, correctedPosition.dy + 35);
      final newTransitionPositionEnd =
          Offset(correctedPosition.dx, correctedPosition.dy - 35);
      final newTransition = Transition(
          start: newTransitionPositionStart, end: newTransitionPositionEnd);
      ref.read(petriNetProvider.notifier).addTransition(newTransition);
      print(
          "🟨 Dodano tranzycję na pozycji: $newTransitionPositionStart, $newTransitionPositionEnd");

      updateState(selectedElement: null, selectionMessage: '');
    } else if (state.selectedElement is Arc) {
      handleArcSelection(correctedPosition, petriNetState, ref);
    }
  }

  /// 🔥 Obsługa wyboru łuku (pierwszy i drugi klik)
  void handleArcSelection(
      Offset scenePosition, PetriNet petriNetState, WidgetRef ref) {
    if (state.startElement == null) {
      // 🔥 Wybieramy pierwszy element (skąd wychodzi łuk)
      final selected = detectElement(scenePosition, petriNetState);
      if (selected != null) {
        updateState(
            startElement: selected, selectionMessage: "Kliknij drugi element");
        print("✅ Wybrano pierwszy element: ${selected.label}");
      } else {
        print("❌ Kliknięto w pustą przestrzeń.");
      }
    } else if (state.endElement == null) {
      // 🔥 Wybieramy drugi element (gdzie łuk ma dochodzić)
      final selected = detectElement(scenePosition, petriNetState);
      if (selected != null) {
        updateState(endElement: selected);
        if ((state.startElement is States && selected is States) ||
            (state.startElement is Transition && selected is Transition)) {
          updateState(
              endElement: null,
              startElement: null,
              selectedElement: null,
              selectionMessage: 'Nie można łączyć 2 tych samych elementów!');
          return;
        }
        if (arcExists(state.startElement, selected)) {
          updateState(
              endElement: null,
              startElement: null,
              selectedElement: null,
              selectionMessage: 'To połączenie już istnieje.');
          return;
        }
        createArc(ref);
      } else {
        print("❌ Kliknięto w pustą przestrzeń.");
      }
    }
  }

  /// 🔍 Wykrywa kliknięty element (stan lub tranzycję)
  dynamic detectElement(Offset scenePosition, PetriNet petriNetState) {
    return PetriNetUtils.detectState(scenePosition, petriNetState) ??
        PetriNetUtils.detectTransition(scenePosition, petriNetState);
  }

  /// 🔥 Tworzenie i dodawanie łuku
  void createArc(WidgetRef ref) {
    if (state.startElement != null && state.endElement != null) {
      final newArrow = Arc(
          start: state.startElement is States
              ? state.startElement.center
              : Offset(
                  (state.startElement.start.dx + state.startElement.end.dx) / 2,
                  (state.startElement.start.dy + state.startElement.end.dy) / 2,
                ),
          end: state.endElement is States
              ? state.endElement.center
              : Offset(
                  (state.endElement.start.dx + state.endElement.end.dx) / 2,
                  (state.endElement.start.dy + state.endElement.end.dy) / 2,
                ),
          arrowPosition: 'end',
          startState: state.startElement is States
              ? state.startElement.label
              : state.endElement.label,
          startTransition: state.endElement is Transition
              ? state.endElement.label
              : state.startElement.label);

      ref
          .read(petriNetProvider.notifier)
          .addArrow(newArrow, state.startElement, state.endElement);

      print(
          "➡ Dodano łuk od ${state.startElement.label} do ${state.endElement.label}");

      resetSelection();
    }
  }

  bool arcExists(dynamic startElement, dynamic selectedElement) {
    final selectedLabel = selectedElement.label;

    return startElement.outgoingArcs.any((arc) {
      if (startElement is States) {
        return arc.startTransition == selectedLabel;
      } else {
        return arc.startState == selectedLabel;
      }
    });
  }
}

final petriNetAdderProvider =
    StateNotifierProvider<PetriNetAdderNotifier, PetriNetElementAdder?>((ref) {
  return PetriNetAdderNotifier();
});
