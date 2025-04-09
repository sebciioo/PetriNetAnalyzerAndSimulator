import 'dart:ui';

bool isPointNearLine(Offset p, Offset start, Offset end, double tolerance) {
  double dx = end.dx - start.dx;
  double dy = end.dy - start.dy;

  if (dx == 0 && dy == 0) {
    // Start i koniec są w tym samym miejscu (nie powinno się zdarzyć)
    return (p - start).distance < tolerance;
  }

  // Obliczamy współczynnik t dla najkrótszej odległości od punktu p do linii
  double t =
      ((p.dx - start.dx) * dx + (p.dy - start.dy) * dy) / (dx * dx + dy * dy);
  t = t.clamp(0, 1);

  // Punkt na linii, który jest najbliżej kliknięcia
  Offset closestPoint = Offset(
    start.dx + t * dx,
    start.dy + t * dy,
  );

  // Sprawdzamy, czy punkt jest wystarczająco blisko
  return (p - closestPoint).distance < tolerance;
}
