import 'dart:ui';

class PetriNet {
  List<Arc> arcs = []; // Zmieniamy na modyfikowalną listę
  List<States> states = []; // Zmieniamy na modyfikowalną listę
  List<Transition> transitions = []; // Zmieniamy na modyfikowalną listę
}

class Arc {
  final Offset start; // Punkt początkowy łuku
  final Offset end; // Punkt końcowy łuku
  final String? label; // Etykieta łuku
  final String? arrowPosition; // "start", "end" lub null

  Arc({
    required this.start,
    required this.end,
    this.label,
    this.arrowPosition,
  });
}

class States {
  final Offset center; // Współrzędne środka stanu
  final double radius; // Promień koła
  final String? label; // Etykieta stanu
  int tokens; // Liczba tokenów w stanie
  final List<Arc> incomingArcs; // Wchodzące łuki
  final List<Arc> outgoingArcs; // Wychodzące łuki

  States({
    required this.center,
    this.radius = 30.0,
    this.label,
    this.tokens = 0,
    List<Arc>? incomingArcs,
    List<Arc>? outgoingArcs,
  })  : incomingArcs = incomingArcs ?? [],
        outgoingArcs = outgoingArcs ?? [];
}

class Transition {
  final Offset start; // Punkt początkowy tranzycji
  final Offset end; // Punkt końcowy tranzycji
  final String? label; // Etykieta tranzycji
  final List<Arc> incomingArcs; // Wchodzące łuki
  final List<Arc> outgoingArcs; // Wychodzące łuki

  Transition({
    required this.start,
    required this.end,
    this.label,
    List<Arc>? incomingArcs,
    List<Arc>? outgoingArcs,
  })  : incomingArcs = incomingArcs ?? [],
        outgoingArcs = outgoingArcs ?? [];
}
