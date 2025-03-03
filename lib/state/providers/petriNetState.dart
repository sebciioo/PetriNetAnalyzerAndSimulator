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
    );
  }

  void updateState({
    List<Arc>? arcs,
    List<States>? states,
    List<Transition>? transitions,
  }) {
    if (state != null) {
      state = PetriNet(
        arcs: arcs ?? state!.arcs,
        states: states ?? state!.states,
        transitions: transitions ?? state!.transitions,
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
        if (t.start == selectedElement.start && t.end == selectedElement.end) {
          return selectedElement as Transition;
        }
        return t;
      }).toList();

      updateState(transitions: updatedTransitions);
    }
  }
}

final petriNetProvider =
    StateNotifierProvider<PetriNetNotifier, PetriNet?>((ref) {
  return PetriNetNotifier();
});

final draggingStateProvider =
    StateProvider<bool>((ref) => false); // TODO do osobnego pliku to wyjebac
