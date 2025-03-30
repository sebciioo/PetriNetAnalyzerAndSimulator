import 'dart:ui';

class PetriNet {
  List<Arc> arcs;
  List<States> states;
  List<Transition> transitions;
  bool isSafe;
  bool isPure;
  bool isConnected;
  bool isInterrupted;
  dynamic isBounded;

  // Konstruktor z domyślnymi pustymi listami
  PetriNet(
      {this.arcs = const [],
      this.states = const [],
      this.transitions = const [],
      this.isSafe = false,
      this.isBounded = false,
      this.isPure = false,
      this.isInterrupted = false,
      this.isConnected = false});

  factory PetriNet.fromJson(Map<String, dynamic> json) {
    print("-----------------ANALIZA------------------");
    print(json['is_interrupted']);
    return PetriNet(
      arcs: List<Arc>.from(json['arcs'].map((arc) => Arc.fromJson(arc))),
      states: List<States>.from(
          json['states'].map((state) => States.fromJson(state))),
      transitions: List<Transition>.from(
          json['transitions'].map((tran) => Transition.fromJson(tran))),
      isSafe: json['is_safe'],
      isPure: json['is_pure'],
      isConnected: json['is_connected'],
      isInterrupted: json['is_interrupted'],
      isBounded: json['is_bounded'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'arcs': arcs.map((arc) => arc.toJson()).toList(),
      'states': states.map((state) => state.toJson()).toList(),
      'transitions': transitions.map((tran) => tran.toJson()).toList(),
      'is_safe': isSafe,
      'is_bounded': isBounded,
      'is_pure': isPure,
      'is_interrupted': isInterrupted,
      'is_connected': isConnected,
    };
  }

  @override
  String toString() {
    return '''
PetriNet:
  Arcs:
    ${arcs.map((arc) => arc.toString()).join('\n    ')}
  States:
    ${states.map((state) => state.toString()).join('\n    ')}
  Transitions:
    ${transitions.map((tran) => tran.toString()).join('\n    ')}
  isSafe: ${isSafe != null ? 'Sieć jest bezpieczna' : 'Sieć nie jest bezpieczna'}
  isBounded: ${isBounded != null ? 'Sieć jest ograniczona' : 'Sieć nie jest ograniczona'}
    ''';
  }
}

class Arc {
  final Offset start; // Punkt początkowy łuku
  final Offset end; // Punkt końcowy łuku
  final String? label; // Etykieta łuku
  final String? arrowPosition; // "start", "end" lub null
  final String startState;
  final String startTransition;

  Arc({
    required this.start,
    required this.end,
    required this.startState,
    required this.startTransition,
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
        startState: json['start_state'],
        startTransition: json['start_transition']);
  }

  // Konwersja do JSON
  Map<String, dynamic> toJson() {
    return {
      'start': [start.dx, start.dy],
      'end': [end.dx, end.dy],
      'label': label,
      'arrow_position': arrowPosition,
      'start_state': startState,
      'start_transition': startTransition
    };
  }

  @override
  String toString() {
    return 'Arc(start: ${start.dx}, ${start.dy}, end: ${end.dx}, ${end.dy}, label: $label, arrowPosition: $arrowPosition)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Arc) return false;
    return start == other.start &&
        end == other.end &&
        label == other.label &&
        arrowPosition == other.arrowPosition;
  }

  // Nadpisanie hashCode
  @override
  int get hashCode => Object.hash(
      start, end, label, arrowPosition, startState, startTransition);

  Arc copyWith(
      {Offset? start,
      Offset? end,
      String? label,
      String? arrowPosition,
      String? startState,
      String? startTransition}) {
    return Arc(
        start: start ?? this.start,
        end: end ?? this.end,
        label: label ?? this.label,
        arrowPosition: arrowPosition ?? this.arrowPosition,
        startState: startState ?? this.startState,
        startTransition: startTransition ?? this.startTransition);
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

  @override
  String toString() {
    return '''
State(center: ${center.dx}, ${center.dy}, radius: $radius, label: $label, tokens: $tokens,
  incomingArcs: ${incomingArcs.map((arc) => arc.toString()).join(', ')},
  outgoingArcs: ${outgoingArcs.map((arc) => arc.toString()).join(', ')});
''';
  }

  States copyWith({
    Offset? center,
    double? radius,
    String? label,
    int? tokens,
    List<Arc>? incomingArcs,
    List<Arc>? outgoingArcs,
  }) {
    return States(
      center: center ?? this.center,
      radius: radius ?? this.radius,
      label: label ?? this.label,
      tokens: tokens ?? this.tokens,
      incomingArcs: incomingArcs ?? this.incomingArcs,
      outgoingArcs: outgoingArcs ?? this.outgoingArcs,
    );
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

  @override
  String toString() {
    return '''
Transition(start: ${start.dx}, ${start.dy}, end: ${end.dx}, ${end.dy}, label: $label,
  incomingArcs: ${incomingArcs.map((arc) => arc.toString()).join(', ')},
  outgoingArcs: ${outgoingArcs.map((arc) => arc.toString()).join(', ')});
''';
  }

  Transition copyWith({
    Offset? start,
    Offset? end,
    String? label,
    List<Arc>? incomingArcs,
    List<Arc>? outgoingArcs,
  }) {
    return Transition(
      start: start ?? this.start,
      end: end ?? this.end,
      label: label ?? this.label,
      incomingArcs: incomingArcs ?? this.incomingArcs,
      outgoingArcs: outgoingArcs ?? this.outgoingArcs,
    );
  }
}
