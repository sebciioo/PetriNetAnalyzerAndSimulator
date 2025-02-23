import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petri_net_front/data/models/mode.dart';

class ModeStateNotifier extends StateNotifier<Mode> {
  ModeStateNotifier() : super(const Mode());

  void setEditingMode() {
    state = const Mode(
      editingMode: true,
      simulationMode: false,
      editModeType: EditModeType.none,
    );
  }

  void setSimulationMode() {
    state = const Mode(
      editingMode: false,
      simulationMode: true,
      editModeType: EditModeType.none,
    );
  }

  void setEditModeType(EditModeType type) {
    state = state.copyWith(editModeType: type);
  }
}

final modeProvider = StateNotifierProvider<ModeStateNotifier, Mode>((ref) {
  return ModeStateNotifier();
});
