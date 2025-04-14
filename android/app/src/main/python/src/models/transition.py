import numpy as np
from src.models import Arc


class Transition:
    def __init__(self, start, end, label=None):
        """
        Reprezentuje tranzycję (linię pionową).

        Parameters:
            start (tuple): Punkt początkowy tranzycji (x1, y1).
            end (tuple): Punkt końcowy tranzycji (x2, y2).
            label (str, optional): Etykieta tranzycji (np. "T1").
        """
        self.start = start
        self.end = end
        self.label = label
        self.incoming_arcs = []  # Lista łuków wchodzących do tranzycji
        self.outgoing_arcs = []  # Lista łuków wychodzących z tranzycji

    def add_incoming_arc(self, arc):
        """
        Dodaj łuk wchodzący do tranzycji.

        Parameters:
            arc (Arc): Łuk wchodzący do tranzycji.
        """
        self.incoming_arcs.append(arc)

    def add_outgoing_arc(self, arc):
        """
        Dodaj łuk wychodzący z tranzycji.

        Parameters:
            arc (Arc): Łuk wychodzący z tranzycji.
        """
        self.outgoing_arcs.append(arc)

    def associate_arc(self, arc, transition, threshold=50):
        from src.detection import detect_intersection, closest_point_on_line
        """
        Sprawdza, czy łuk jest powiązany z tranzycją na podstawie przecięcia
        lub odległości z tolerancją.

        Parameters:
            arc (Arc): Łuk, który ma być sprawdzony i przypisany.
            threshold (int): Maksymalna odległość, aby uznać łuk za powiązany.
        """
        # Pobierz punkty łuku w zależności od pozycji grotu
        if arc.arrow_position == "start":
            arrowhead_x, arrowhead_y = arc.start
            end_x, end_y = arc.end
        else:
            arrowhead_x, arrowhead_y = arc.end
            end_x, end_y = arc.start

        # Sprawdź przecięcie z linią tranzycji
        start = self.start
        end = self.end
        intersection = detect_intersection(
            (start[0], start[1], end[0], end[1]),
            (arrowhead_x, arrowhead_y, end_x, end_y),
        )

        if intersection:
            if intersection:
                ix, iy = intersection

                # Oblicz odległości od punktów start i end łuku do punktu przecięcia
                dist_start = np.linalg.norm(np.array([ix, iy]) - np.array([arrowhead_x, arrowhead_y]))
                dist_end = np.linalg.norm(np.array([ix, iy]) - np.array([end_x, end_y]))

                # Dodaj łuk w zależności od tego, który punkt jest bliżej przecięcia
                if dist_start < dist_end:
                    arc.start_transition = transition.label
                    self.incoming_arcs.append(arc)
                else:
                    arc.start_transition = transition.label
                    self.outgoing_arcs.append(arc)
        else:
            # Jeśli brak przecięcia, sprawdź dystans
            p1 = closest_point_on_line(
                arrowhead_x, arrowhead_y, start[0], start[1], end[0], end[1]
            )
            p2 = closest_point_on_line(
                end_x, end_y, start[0], start[1], end[0], end[1]
            )

            # Oblicz minimalne odległości między punktami
            distances = [
                np.linalg.norm(np.array(p1) - np.array((arrowhead_x, arrowhead_y))),
                np.linalg.norm(np.array(p2) - np.array((end_x, end_y))),
            ]

            min_distance = min(distances)
            if min_distance <= threshold:
                if distances[0] < distances[1]:
                    arc.start_transition = transition.label
                    self.incoming_arcs.append(arc)
                else:
                    arc.start_transition = transition.label
                    self.outgoing_arcs.append(arc)

    def __str__(self):
        return (
            f"Transition(start={self.start}, end={self.end}, label={self.label}, "
            f"incoming={len(self.incoming_arcs)}, outgoing={len(self.outgoing_arcs)})"
        )

    def to_dict(self):
        return {
            "start": [int(coord) for coord in self.start],
            "end": [int(coord) for coord in self.end],
            "label": self.label,
            "incoming_arcs": [arc.to_dict() for arc in self.incoming_arcs],
            "outgoing_arcs": [arc.to_dict() for arc in self.outgoing_arcs],
        }
    
    @classmethod
    def from_dict(cls, data):
        start=tuple(data["start"])
        end=tuple(data["end"])
        label = data["label"]
        transition = cls(start=start, end=end, label=label)
        transition.incoming_arcs = [Arc.from_dict(arc) for arc in data.get("incoming_arcs", [])]
        transition.outgoing_arcs = [Arc.from_dict(arc) for arc in data.get("outgoing_arcs", [])]
        return transition