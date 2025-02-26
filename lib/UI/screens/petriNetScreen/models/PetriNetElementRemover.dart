import 'package:flutter/material.dart';
import 'package:petri_net_front/data/models/petriNet.dart';
import 'package:petri_net_front/UI/utils/petriNetUtils.dart';

class PetriNetElementRemover {
  final TransformationController transformationController;
  final PetriNet petriNetState;

  PetriNetElementRemover({
    required this.transformationController,
    required this.petriNetState,
  });

  Object? handleTap(TapDownDetails details) {
    final Offset correctedPosition = PetriNetUtils.getCorrectedPosition(
        details.localPosition, transformationController.value);

    return PetriNetUtils.detectState(correctedPosition, petriNetState) ??
        PetriNetUtils.detectTransition(correctedPosition, petriNetState) ??
        PetriNetUtils.detectArc(correctedPosition, petriNetState);
  }
}
