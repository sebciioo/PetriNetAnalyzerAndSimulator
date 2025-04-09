import 'package:flutter/material.dart';
import 'package:petri_net_front/UI/utils/pointerNearLine.dart';
import 'package:petri_net_front/UI/utils/calculateClosetPoint.dart';
import 'package:petri_net_front/data/models/petriNet.dart';

class PetriNetUtils {
  static Offset getCorrectedPosition(
      Offset localPosition, Matrix4 transformationMatrix) {
    final Matrix4 inverseMatrix = Matrix4.inverted(transformationMatrix);

    final double x = localPosition.dx * inverseMatrix.entry(0, 0) +
        localPosition.dy * inverseMatrix.entry(0, 1) +
        inverseMatrix.entry(0, 3);

    final double y = localPosition.dx * inverseMatrix.entry(1, 0) +
        localPosition.dy * inverseMatrix.entry(1, 1) +
        inverseMatrix.entry(1, 3);

    return Offset(x, y);
  }

  static States? detectState(Offset correctedPosition, PetriNet petriNetState) {
    for (final state in petriNetState.states) {
      if ((correctedPosition - state.center).distance < 45) {
        return state;
      }
    }
    return null;
  }

  static Transition? detectTransition(
      Offset correctedPosition, PetriNet petriNetState) {
    for (final transition in petriNetState.transitions) {
      if (isPointNearLine(
          correctedPosition, transition.start, transition.end, 10)) {
        return transition;
      }
    }
    return null;
  }

  static Arc? detectArc(Offset correctedPosition, PetriNet petriNetState) {
    for (final arc in petriNetState.arcs) {
      final state = petriNetState.states.firstWhere(
          (s) => s.outgoingArcs.contains(arc) || s.incomingArcs.contains(arc),
          orElse: () => States(center: Offset.zero));

      final transition = petriNetState.transitions.firstWhere(
          (t) => t.incomingArcs.contains(arc) || t.outgoingArcs.contains(arc),
          orElse: () => Transition(start: Offset.zero, end: Offset.zero));

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
