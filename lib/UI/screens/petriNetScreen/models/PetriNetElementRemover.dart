import 'package:flutter/material.dart';
import 'package:petri_net_front/UI/utils/pointerNearLine.dart';
import 'package:petri_net_front/UI/utils/calculateClosetPoint.dart';
import 'package:petri_net_front/data/models/petriNet.dart';

class PetriNetElementRemover {
  final TransformationController transformationController;
  final PetriNet petriNetState;

  PetriNetElementRemover({
    required this.transformationController,
    required this.petriNetState,
  });

  Object? handleTap(TapDownDetails details) {
    final Offset correctedPosition =
        _getCorrectedPosition(details.localPosition);

    return _removeState(correctedPosition) ??
        _removeTransition(correctedPosition) ??
        _removeArc(correctedPosition);
  }

  Offset _getCorrectedPosition(Offset localPosition) {
    final Matrix4 inverseMatrix =
        Matrix4.inverted(transformationController.value);

    final double x = localPosition.dx * inverseMatrix.entry(0, 0) +
        localPosition.dy * inverseMatrix.entry(0, 1) +
        inverseMatrix.entry(0, 3);

    final double y = localPosition.dx * inverseMatrix.entry(1, 0) +
        localPosition.dy * inverseMatrix.entry(1, 1) +
        inverseMatrix.entry(1, 3);

    return Offset(x, y);
  }

  States? _removeState(Offset correctedPosition) {
    for (final state in petriNetState.states) {
      if ((correctedPosition - state.center).distance < 45) {
        return state;
      }
    }
    return null;
  }

  Transition? _removeTransition(Offset correctedPosition) {
    for (final transition in petriNetState.transitions) {
      if (isPointNearLine(
          correctedPosition, transition.start, transition.end, 10)) {
        return transition;
      }
    }
    return null;
  }

  Arc? _removeArc(Offset correctedPosition) {
    for (final arc in petriNetState.arcs) {
      final state = petriNetState.states.firstWhere(
          (s) => s.outgoingArcs.contains(arc) || s.incomingArcs.contains(arc));

      final transition = petriNetState.transitions.firstWhere(
          (t) => t.incomingArcs.contains(arc) || t.outgoingArcs.contains(arc));

      final centerX = (transition.start.dx + transition.end.dx) / 2;
      final centerY = (transition.start.dy + transition.end.dy) / 2;

      final adjustedStart = calculateClosestPoint(
        state.center,
        40,
        state.center,
        Offset(centerX, centerY),
      );

      final adjustedEnd = Offset(centerX, centerY);

      if (isPointNearLine(correctedPosition, adjustedStart, adjustedEnd, 10)) {
        return arc;
      }
    }
    return null;
  }
}
