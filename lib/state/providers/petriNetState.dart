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

  void updateState() {
    if (state != null) {
      state = PetriNet(
        arcs: List.from(state!.arcs),
        states: List.from(state!.states),
        transitions: List.from(state!.transitions),
      );
    }
  }
}

final petriNetProvider =
    StateNotifierProvider<PetriNetNotifier, PetriNet?>((ref) {
  return PetriNetNotifier();
});
