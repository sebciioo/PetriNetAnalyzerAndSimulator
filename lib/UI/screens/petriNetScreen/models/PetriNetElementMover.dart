import 'package:flutter/material.dart';
import 'package:petri_net_front/data/models/petriNet.dart';
import 'package:petri_net_front/UI/utils/petriNetUtils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petri_net_front/state/providers/petriNetState.dart';

class PetriNetElementMover {
  PetriNetElementMover({
    required this.transformationController,
    required this.petriNetState,
  });

  final TransformationController transformationController;
  final PetriNet petriNetState;
  dynamic selectedElement;

  void handleDragStart(DragStartDetails details, WidgetRef ref) {
    final Offset correctedPosition = PetriNetUtils.getCorrectedPosition(
        details.localPosition, transformationController.value);

    final element =
        PetriNetUtils.detectState(correctedPosition, petriNetState) ??
            PetriNetUtils.detectTransition(correctedPosition, petriNetState);

    if (element != null) {
      ref.read(draggingStateProvider.notifier).state = true;
      ref.read(petriNetProvider.notifier).setSelectedElement(element);
    }
  }

  void handleDragUpdate(DragUpdateDetails details, WidgetRef ref) {
    final petriNetNotifier = ref.read(petriNetProvider.notifier);
    final selectedElement = petriNetNotifier.selectedElement;

    if (selectedElement == null) return;

    if (selectedElement is States) {
      final newElement = selectedElement.copyWith(
        center: selectedElement.center + details.delta,
      );

      petriNetNotifier.setSelectedElement(newElement);
    } else if (selectedElement is Transition) {
      final newElement = selectedElement.copyWith(
        start: selectedElement.start + details.delta,
        end: selectedElement.end + details.delta,
      );

      petriNetNotifier.setSelectedElement(newElement);
    }
    petriNetNotifier.updateElementPosition();
  }

  void handleDragEnd(WidgetRef ref) {
    ref.read(draggingStateProvider.notifier).state = false;
    ref.read(petriNetProvider.notifier).updateElementPosition();
    ref.read(petriNetProvider.notifier).setSelectedElement(null);
  }
}
