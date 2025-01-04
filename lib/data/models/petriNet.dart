import 'dart:ui';

class PetriNet {
  List<Arc> arcs;
  List<States> states;
  List<Transition> transitions;

  // Konstruktor z domyślnymi pustymi listami
  PetriNet(
      {this.arcs = const [],
      this.states = const [],
      this.transitions = const []});

  factory PetriNet.fromJson(Map<String, dynamic> json) {
    return PetriNet(
      arcs: List<Arc>.from(json['arcs'].map((arc) => Arc.fromJson(arc))),
      states: List<States>.from(
          json['states'].map((state) => States.fromJson(state))),
      transitions: List<Transition>.from(
          json['transitions'].map((tran) => Transition.fromJson(tran))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'arcs': arcs.map((arc) => arc.toJson()).toList(),
      'states': states.map((state) => state.toJson()).toList(),
      'transitions': transitions.map((tran) => tran.toJson()).toList(),
    };
  }
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

  // Konwersja z JSON
  factory Arc.fromJson(Map<String, dynamic> json) {
    return Arc(
      start: Offset(
        (json['start'][0] as num).toDouble(),
        (json['start'][1] as num).toDouble(),
      ),
      end: Offset(
        (json['end'][0] as num).toDouble(),
        (json['end'][1] as num).toDouble(),
      ),
      label: json['label'],
      arrowPosition: json['arrow_position'],
    );
  }

  // Konwersja do JSON
  Map<String, dynamic> toJson() {
    return {
      'start': [start.dx, start.dy],
      'end': [end.dx, end.dy],
      'label': label,
      'arrow_position': arrowPosition,
    };
  }
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

  // Konwersja z JSON
  factory States.fromJson(Map<String, dynamic> json) {
    return States(
      center: Offset(
        (json['center'][0] as num).toDouble(),
        (json['center'][1] as num).toDouble(),
      ),
      radius: (json['radius'] as num).toDouble(),
      label: json['label'],
      tokens: json['tokens'] ?? 0,
      incomingArcs: (json['incoming_arcs'] as List<dynamic>?)
              ?.map((arc) => Arc.fromJson(arc))
              .toList() ??
          [],
      outgoingArcs: (json['outgoing_arcs'] as List<dynamic>?)
              ?.map((arc) => Arc.fromJson(arc))
              .toList() ??
          [],
    );
  }

  // Konwersja do JSON
  Map<String, dynamic> toJson() {
    return {
      'center': [center.dx, center.dy],
      'radius': radius,
      'label': label,
      'tokens': tokens,
      'incoming_arcs': incomingArcs.map((arc) => arc.toJson()).toList(),
      'outgoing_arcs': outgoingArcs.map((arc) => arc.toJson()).toList(),
    };
  }
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

  // Konwersja z JSON
  factory Transition.fromJson(Map<String, dynamic> json) {
    return Transition(
      start: Offset(
        (json['start'][0] as num).toDouble(),
        (json['start'][1] as num).toDouble(),
      ),
      end: Offset(
        (json['end'][0] as num).toDouble(),
        (json['end'][1] as num).toDouble(),
      ),
      label: json['label'],
      incomingArcs: (json['incoming_arcs'] as List<dynamic>?)
              ?.map((arc) => Arc.fromJson(arc))
              .toList() ??
          [],
      outgoingArcs: (json['outgoing_arcs'] as List<dynamic>?)
              ?.map((arc) => Arc.fromJson(arc))
              .toList() ??
          [],
    );
  }

  // Konwersja do JSON
  Map<String, dynamic> toJson() {
    return {
      'start': [start.dx, start.dy],
      'end': [end.dx, end.dy],
      'label': label,
      'incoming_arcs': incomingArcs.map((arc) => arc.toJson()).toList(),
      'outgoing_arcs': outgoingArcs.map((arc) => arc.toJson()).toList(),
    };
  }
}
