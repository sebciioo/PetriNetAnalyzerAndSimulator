import 'dart:math';
import 'dart:ui';

Offset calculateClosestPoint(
    Offset circleCenter, double radius, Offset lineStart, Offset lineEnd) {
  final dx = lineEnd.dx - lineStart.dx;
  final dy = lineEnd.dy - lineStart.dy;
  final toStart =
      Offset(lineStart.dx - circleCenter.dx, lineStart.dy - circleCenter.dy);
  final a = dx * dx + dy * dy;
  final b = 2 * (toStart.dx * dx + toStart.dy * dy);
  final c = toStart.dx * toStart.dx + toStart.dy * toStart.dy - radius * radius;

  final discriminant = b * b - 4 * a * c;

  if (discriminant < 0) {
    final nearestPoint = Offset(
      circleCenter.dx + toStart.dx * radius / toStart.distance,
      circleCenter.dy + toStart.dy * radius / toStart.distance,
    );
    return nearestPoint;
  }
  final t1 = (-b - sqrt(discriminant)) / (2 * a);
  final t2 = (-b + sqrt(discriminant)) / (2 * a);
  final tClosest = (t1 >= 0 && t1 <= 1)
      ? t1
      : (t2 >= 0 && t2 <= 1)
          ? t2
          : (t1 < 0 ? t2 : t1);

  final intersection = Offset(
    lineStart.dx + tClosest * dx,
    lineStart.dy + tClosest * dy,
  );

  return intersection;
}
