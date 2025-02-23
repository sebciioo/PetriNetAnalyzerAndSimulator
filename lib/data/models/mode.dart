enum EditModeType { none, addTokens, addElements, removeElements, moveElements }

class Mode {
  const Mode({
    this.editingMode = false,
    this.simulationMode = true,
    this.editModeType = EditModeType.none,
  });
  final bool editingMode;
  final bool simulationMode;
  final EditModeType editModeType;

  Mode copyWith({
    bool? editingMode,
    bool? simulationMode,
    EditModeType? editModeType,
  }) {
    return Mode(
      editingMode: editingMode ?? this.editingMode,
      simulationMode: simulationMode ?? this.simulationMode,
      editModeType: editModeType ?? this.editModeType,
    );
  }
}
