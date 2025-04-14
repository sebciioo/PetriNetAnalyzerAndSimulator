import 'dart:ui';

bool isPointNearLine(Offset p, Offset start, Offset end, double tolerance) {
  double dx = end.dx - start.dx;
  double dy = end.dy - start.dy;
  if (dx == 0 && dy == 0) {
    return (p - start).distance < tolerance;
  }
  double t =
      ((p.dx - start.dx) * dx + (p.dy - start.dy) * dy) / (dx * dx + dy * dy);
  t = t.clamp(0, 1);
  Offset closestPoint = Offset(
    start.dx + t * dx,
    start.dy + t * dy,
  );
  return (p - closestPoint).distance < tolerance;
}
