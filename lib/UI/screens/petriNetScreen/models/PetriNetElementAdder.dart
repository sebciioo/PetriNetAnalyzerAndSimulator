import 'package:flutter/material.dart';
import 'package:petri_net_front/data/models/petriNet.dart';
import 'package:petri_net_front/UI/utils/petriNetUtils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petri_net_front/state/providers/petriNetState.dart';
import 'package:widget_arrows/arrows.dart';

class PetriNetElementAdder {
  final dynamic selectedElement;
  final dynamic startElement;
  final dynamic endElement;
  final String selectionMessage;

  PetriNetElementAdder({
    this.selectedElement,
    this.startElement,
    this.endElement,
    this.selectionMessage = "",
  });

  PetriNetElementAdder copyWith({
    dynamic selectedElement,
    dynamic startElement,
    dynamic endElement,
    String? selectionMessage,
  }) {
    return PetriNetElementAdder(
      selectedElement: selectedElement ?? this.selectedElement,
      startElement: startElement ?? this.startElement,
      endElement: endElement ?? this.endElement,
      selectionMessage: selectionMessage ?? this.selectionMessage,
    );
  }
}
