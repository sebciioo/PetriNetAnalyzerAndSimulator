import '../../data/models/petriNet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PetriNetNotifier extends StateNotifier<PetriNet?> {
  PetriNetNotifier() : super(null);

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
}

final petriNetProvider =
    StateNotifierProvider<PetriNetNotifier, PetriNet?>((ref) {
  return PetriNetNotifier();
});
