import 'package:flutter/material.dart';

import '../../data/models/petriNet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PetriNetNotifier extends StateNotifier<PetriNet?> {
  PetriNetNotifier() : super(null);

  dynamic selectedElement;

  void setSelectedElement(dynamic element) {
    selectedElement = element;
  }

  void setPetriNet(PetriNet petriNetResponse) {
    state = PetriNet(
        arcs: petriNetResponse.arcs,
        states: petriNetResponse.states,
        transitions: petriNetResponse.transitions,
        isSafe: petriNetResponse.isSafe,
        isLive: petriNetResponse.isLive,
        isBounded: petriNetResponse.isBounded);
  }

  void updateState(
      {List<Arc>? arcs,
      List<States>? states,
      List<Transition>? transitions,
      bool? isSafe,
      bool? isLive,
      dynamic isBounded}) {
    if (state != null) {
      state = PetriNet(
        arcs: arcs ?? state!.arcs,
        states: states ?? state!.states,
        transitions: transitions ?? state!.transitions,
        isSafe: isSafe ?? state!.isSafe,
        isLive: isLive ?? state!.isLive,
        isBounded: isBounded ?? state!.isBounded,
      );
    }
  }

  void addToken(States selectedState) {
    if (state != null) {
      final updatedStates = state!.states.map((state) {
        if (state == selectedState) {
          return state..tokens += 1;
        }
        return state;
      }).toList();
      updateState(
        states: updatedStates,
      );
    }
  }

  void removeToken(States selectedState) {
    if (state != null) {
      final updatedStates = state!.states.map((state) {
        if (state == selectedState) {
          return state..tokens -= 1;
        }
        return state;
      }).toList();
      updateState(
        states: updatedStates,
      );
    }
  }

  void removeState(States selectedState) {
    if (state != null) {
      //Usuwamy łuki powiązane ze stanem
      final updatedArcs = state!.arcs
          .where((arc) => !(selectedState.outgoingArcs.contains(arc) ||
              selectedState.incomingArcs.contains(arc)))
          .toList();

      //Usuwamy powiązane łuki również z tranzycji
      final updatedTransitions = state!.transitions.map((transition) {
        return transition.copyWith(
          incomingArcs: transition.incomingArcs
              .where((arc) => !selectedState.outgoingArcs.contains(arc))
              .toList(),
          outgoingArcs: transition.outgoingArcs
              .where((arc) => !selectedState.incomingArcs.contains(arc))
              .toList(),
        );
      }).toList();

      //Usuwamy stan z listy stanów
      final updatedStates =
          state!.states.where((s) => s != selectedState).toList();

      // Usuwamy tranzycje, które nie mają żadnych połączeń (puste incoming i outgoing arcs)
      //final cleanedTransitions = updatedTransitions
      //    .where((transition) =>
      //        transition.incomingArcs.isNotEmpty ||
      //        transition.outgoingArcs.isNotEmpty)
      //    .toList();

      //Aktualizacja stanu
      updateState(
          states: updatedStates,
          transitions: updatedTransitions,
          arcs: updatedArcs);

      print('❌ Usunięto stan oraz powiązane łuki');
    }
  }

  void removeTransition(Transition selectedTransition) {
    if (state != null) {
      // Usuwamy łuki powiązane z tranzycją
      final updatedArcs = state!.arcs
          .where((arc) => !(selectedTransition.outgoingArcs.contains(arc) ||
              selectedTransition.incomingArcs.contains(arc)))
          .toList();

      //Usuwamy powiązane łuki również ze stanów
      final updatedStates = state!.states.map((state) {
        return state.copyWith(
          incomingArcs: state.incomingArcs
              .where((arc) => !selectedTransition.outgoingArcs.contains(arc))
              .toList(),
          outgoingArcs: state.outgoingArcs
              .where((arc) => !selectedTransition.incomingArcs.contains(arc))
              .toList(),
        );
      }).toList();

      //Usuwamy tranzycję z listy tranzycji
      final updatedTransitions =
          state!.transitions.where((t) => t != selectedTransition).toList();

      // Usuwamy stan, które nie ma żadnych połączeń (puste incoming i outgoing arcs)
      //final cleanedStates = updatedStates
      //    .where((state) =>
      //        state.incomingArcs.isNotEmpty || state.outgoingArcs.isNotEmpty)
      //    .toList();

      //Aktualizacja stanu
      updateState(
          transitions: updatedTransitions,
          states: updatedStates,
          arcs: updatedArcs);

      print('❌ Usunięto tranzycję oraz powiązane łuki');
    }
  }

  void removeArc(Arc selectedArc) {
    if (state != null) {
      final updatedArcs =
          state!.arcs.where((arc) => arc != selectedArc).toList();

      final updatedStates = state!.states
          .map((state) => state.copyWith(
                outgoingArcs: state.outgoingArcs
                    .where((arc) => arc != selectedArc)
                    .toList(),
                incomingArcs: state.incomingArcs
                    .where((arc) => arc != selectedArc)
                    .toList(),
              ))
          .toList();

      final updatedTransitions = state!.transitions
          .map((transition) => transition.copyWith(
                outgoingArcs: transition.outgoingArcs
                    .where((arc) => arc != selectedArc)
                    .toList(),
                incomingArcs: transition.incomingArcs
                    .where((arc) => arc != selectedArc)
                    .toList(),
              ))
          .toList();

      // Usuwamy stan, które nie ma żadnych połączeń (puste incoming i outgoing arcs)
      //final cleanedStates = updatedStates
      //    .where((state) =>
      //        state.incomingArcs.isNotEmpty || state.outgoingArcs.isNotEmpty)
      //   .toList();

      // Usuwamy tranzycje, które nie mają żadnych połączeń (puste incoming i outgoing arcs)
      //final cleanedTransitions = updatedTransitions
      //    .where((transition) =>
      //        transition.incomingArcs.isNotEmpty ||
      //        transition.outgoingArcs.isNotEmpty)
      //    .toList();

      updateState(
          arcs: updatedArcs,
          states: updatedStates,
          transitions: updatedTransitions);
      print('❌ Usunięto łuk globalnie: $selectedArc');
    }
  }

  void updateElementPosition() {
    if (state == null || selectedElement == null) return;

    if (selectedElement is States) {
      final List<States> updatedStates = state!.states.map((s) {
        if (s.label == selectedElement.label) {
          return selectedElement as States;
        }
        return s;
      }).toList();

      updateState(states: updatedStates);
    } else if (selectedElement is Transition) {
      final List<Transition> updatedTransitions = state!.transitions.map((t) {
        if (t.label == selectedElement.label) {
          return selectedElement as Transition;
        }
        return t;
      }).toList();

      updateState(transitions: updatedTransitions);
    }
  }

  void addState(States newState) {
    int maxNumber = 0;

    for (var state in state!.states) {
      String label = state.label!;
      String numberPart = label.substring(1);
      int? number = int.tryParse(numberPart);
      if (number != null && number > maxNumber) {
        maxNumber = number;
      }
    }

    final newLabel = "S${maxNumber + 1}";
    final newLabeledState = newState.copyWith(label: newLabel);

    final updatedStates = state!.states.map((s) => s.copyWith()).toList()
      ..add(newLabeledState);

    updateState(states: updatedStates);
  }

  void addTransition(Transition newTransition) {
    int maxNumber = 0;

    for (var transition in state!.transitions) {
      String label = transition.label!;
      String numberPart = label.substring(1);
      int? number = int.tryParse(numberPart);
      if (number != null && number > maxNumber) {
        maxNumber = number;
      }
    }

    final newLabel = "S${maxNumber + 1}";
    final newLabeledTransition = newTransition.copyWith(label: newLabel);

    final updatedTransitions = state!.transitions
        .map((s) => s.copyWith())
        .toList()
      ..add(newLabeledTransition);

    updateState(transitions: updatedTransitions);
  }

  void addArrow(Arc newArrow, dynamic startElement, dynamic endElement) {
    final updatedArcs = state!.arcs.map((s) => s.copyWith()).toList()
      ..add(newArrow);

    if (startElement is States && endElement is Transition) {
      // Stan -> Tranzycja
      final updatedStates = state!.states.map((s) {
        if (s == startElement) {
          return s.copyWith(outgoingArcs: [...s.outgoingArcs, newArrow]);
        }
        return s;
      }).toList();

      final updatedTransitions = state!.transitions.map((t) {
        if (t == endElement) {
          return t.copyWith(incomingArcs: [...t.incomingArcs, newArrow]);
        }
        return t;
      }).toList();
      updateState(
          arcs: updatedArcs,
          states: updatedStates,
          transitions: updatedTransitions);
    } else if (startElement is Transition && endElement is States) {
      // Tranzycja -> Stan
      final updatedTransitions = state!.transitions.map((t) {
        if (t == startElement) {
          return t.copyWith(outgoingArcs: [...t.outgoingArcs, newArrow]);
        }
        return t;
      }).toList();

      final updatedStates = state!.states.map((s) {
        if (s == endElement) {
          return s.copyWith(incomingArcs: [...s.incomingArcs, newArrow]);
        }
        return s;
      }).toList();

      updateState(
          arcs: updatedArcs,
          states: updatedStates,
          transitions: updatedTransitions);
    }
    print("➡ Dodano nowy łuk od ${newArrow.start} do ${newArrow.end}");
  }
}

final petriNetProvider =
    StateNotifierProvider<PetriNetNotifier, PetriNet?>((ref) {
  return PetriNetNotifier();
});

final draggingStateProvider =
    StateProvider<bool>((ref) => false); // TODO do osobnego pliku to wyjebac
