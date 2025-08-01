import 'dart:math';
import 'package:petri_net_front/UI/utils/calculateClosetPoint.dart';
import 'package:flutter/material.dart';
import 'package:petri_net_front/data/models/petriNet.dart';
import 'package:arrow_path/arrow_path.dart';

class PetriNetPainter extends CustomPainter {
  final PetriNet petriNet;
  final double transitionHeight = 70.0;
  final double transitionWidth = 5.0;
  final double constStateRadius = 40;

  PetriNetPainter({required this.petriNet});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint statePaint = Paint()
      ..color = Color(0xFF00bcd4)
      ..style = PaintingStyle.fill;

    final Paint transitionPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = transitionWidth;

    final Paint arcPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final textStyle = TextStyle(color: Colors.black, fontSize: 14);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Rysowanie stanów
    for (final state in petriNet.states) {
      canvas.drawCircle(state.center, constStateRadius, statePaint);

      // Rysowanie etykiety stanu
      if (true) {
        textPainter.text = TextSpan(text: state.label, style: textStyle);
        textPainter.layout();
        textPainter.paint(
          canvas,
          state.center.translate(-state.radius / 2, -state.radius - 10),
        );
      }

      // Rysowanie tokenów
      if (state.tokens > 0) {
        if (state.tokens <= 3) {
          // Rysowanie tokenów jako kółek
          final tokenPaint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;

          final positions =
              _getTokenPositions(state.center, constStateRadius, state.tokens);

          for (final pos in positions) {
            canvas.drawCircle(pos, constStateRadius / 4, tokenPaint);
          }
        } else {
          // Rysowanie liczby tokenów
          textPainter.text = TextSpan(
            text: '${state.tokens}',
            style: textStyle.copyWith(color: Colors.white, fontSize: 35),
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(state.center.dx - textPainter.width / 2,
                state.center.dy - textPainter.height / 2),
          );
        }
      }
    }

    // Rysowanie tranzycji
    for (final transition in petriNet.transitions) {
      // Obliczamy środek tranzycji na podstawie startu i końca
      final centerX = (transition.start.dx + transition.end.dx) / 2;
      final centerY = (transition.start.dy + transition.end.dy) / 2;

      Offset start, end;

      // Sprawdzamy orientację tranzycji
      if ((transition.end.dx - transition.start.dx).abs() >
          (transition.end.dy - transition.start.dy).abs()) {
        // Pozioma tranzycja
        start = Offset(centerX - transitionHeight / 2, centerY);
        end = Offset(centerX + transitionHeight / 2, centerY);
      } else {
        // Pionowa tranzycja
        start = Offset(centerX, centerY - transitionHeight / 2);
        end = Offset(centerX, centerY + transitionHeight / 2);
      }

      // Rysujemy linię tranzycji
      canvas.drawLine(start, end, transitionPaint);

      // Rysowanie etykiety tranzycji
      if (true) {
        textPainter.text = TextSpan(text: transition.label, style: textStyle);
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(centerX - 10, centerY - transitionHeight / 2 - 10),
        );
      }
    }

    for (final state in petriNet.states) {
      // Rysowanie wychodzących łuków
      for (final arc in state.outgoingArcs) {
        // Punkt końcowy łuku na krawędzi tranzycji
        final transition = petriNet.transitions.firstWhere(
          (t) => t.incomingArcs.contains(arc),
          orElse: () => throw Exception('Nie znaleziono tranzycji dla łuku.'),
        );
        final centerX = (transition.start.dx + transition.end.dx) / 2;
        final centerY = (transition.start.dy + transition.end.dy) / 2;
        final adjustedStart = calculateClosestPoint(state.center,
            constStateRadius, state.center, Offset(centerX, centerY));
        final adjustedEnd = Offset(centerX, centerY);

        _drawArrow(canvas, arcPaint, adjustedStart, adjustedEnd, arc.label,
            textPainter, textStyle);
      }

      // Rysowanie wchodzących łuków
      for (final arc in state.incomingArcs) {
        // Punkt początkowy łuku na krawędzi tranzycji
        final transition = petriNet.transitions.firstWhere(
          (t) => t.outgoingArcs.contains(arc),
          orElse: () => throw Exception('Nie znaleziono tranzycji dla łuku.'),
        );

        final centerX = (transition.start.dx + transition.end.dx) / 2;
        final centerY = (transition.start.dy + transition.end.dy) / 2;
        final adjustedStart = Offset(centerX, centerY);
        //final adjustedEnd = state.center;
        final adjustedEnd = calculateClosestPoint(state.center,
            constStateRadius, state.center, Offset(centerX, centerY));

        _drawArrow(canvas, arcPaint, adjustedStart, adjustedEnd, arc.label,
            textPainter, textStyle);
      }
    }
  }

  /// Rysowanie łuku z grotem
  void _drawArrow(
    Canvas canvas,
    Paint paint,
    Offset start,
    Offset end,
    String? label,
    TextPainter textPainter,
    TextStyle textStyle,
  ) {
    Path arcPath = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);

    arcPath = ArrowPath.addTip(arcPath);

    canvas.drawPath(arcPath, paint);
  }

  List<Offset> _getTokenPositions(
      Offset center, double radius, int tokenCount) {
    const double offsetFactor = 0.35;
    switch (tokenCount) {
      case 1:
        return [center];
      case 2:
        return [
          Offset(center.dx - radius * offsetFactor, center.dy),
          Offset(center.dx + radius * offsetFactor, center.dy),
        ];
      case 3:
        return [
          Offset(center.dx - radius * offsetFactor,
              center.dy + radius * offsetFactor),
          Offset(center.dx + radius * offsetFactor,
              center.dy + radius * offsetFactor),
          Offset(center.dx, center.dy - radius * offsetFactor),
        ];
      default:
        return [];
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
