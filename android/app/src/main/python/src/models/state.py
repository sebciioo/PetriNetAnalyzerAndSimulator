import math
from src.models import Arc
import cv2
import numpy as np


class State:
    def __init__(self, center, radius, tokens=0, label=None):
        """
        Reprezentuje koło (stan).

        Parameters:
            center (tuple): Współrzędne środka koła (x, y).
            radius (int): Promień koła.
            label (str, optional): Etykieta stanu (np. "S1").
            marking (boolean): Informacja czy w stanie znajduję się token
        """
        self.center = center
        self.radius = radius
        self.tokens = tokens
        self.label = label
        self.incoming_arcs = []  # Lista łuków wchodzących do stanu
        self.outgoing_arcs = []  # Lista łuków wychodzących ze stanu

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

    def associate_arc(self, arc, state, distance_threshold=50):
        """
        Sprawdza, czy łuk znajduje się w pobliżu stanu koła, i przypisuje go jako
        wchodzący (incoming) lub wychodzący (outgoing).

        Parameters:
            arc (Arc): Łuk, który ma być sprawdzony i przypisany.
            distance_threshold (int): Maksymalna odległość od stanu do końca łuku.
        """
        if arc.arrow_position == "start":
            arrowhead_x, arrowhead_y = map(float, arc.start)
            end_x, end_y = map(float, arc.end)
        else:
            arrowhead_x, arrowhead_y = map(float, arc.end)
            end_x, end_y = map(float, arc.start)
        center_x, center_y = map(float, self.center)
        radius = float(self.radius)

        # Oblicz odległości od środka stanu do punktów start i end łuku
        dist_to_start = np.sqrt((center_x - arrowhead_x) ** 2 + (center_y - arrowhead_y) ** 2)
        dist_to_end = np.sqrt((center_x - end_x) ** 2 + (center_y - end_y) ** 2)

        # Sprawdź, który punkt jest bliżej stanu i przypisz łuk odpowiednio
        if dist_to_start <= distance_threshold+radius:
            arc.start_state = state.label
            self.incoming_arcs.append(arc)
        elif dist_to_end <= distance_threshold+radius:
            arc.start_state = state.label
            self.outgoing_arcs.append(arc)

    def assign_tokens(self, tokens):
        """Przypisuje tokeny do stanu, jeśli znajdują się wewnątrz koła."""
        for token in tokens:
            distance = np.sqrt((token.pt[0] - self.center[0]) ** 2 + (token.pt[1] - self.center[1]) ** 2)
            if distance <= self.radius:
                self.tokens += 1

    def __str__(self):
        return (
            f"State(center={self.center}, radius={self.radius}, tokens={self.tokens}, label={self.label}, "
            f"incoming={len(self.incoming_arcs)}, outgoing={len(self.outgoing_arcs)})"
        )

    def to_dict(self):
        return {
            "center": [int(coord) for coord in self.center],
            "radius": int(self.radius),
            "tokens": int(self.tokens),
            "label": self.label,
            "incoming_arcs": [arc.to_dict() for arc in self.incoming_arcs],
            "outgoing_arcs": [arc.to_dict() for arc in self.outgoing_arcs],
        }
    
    @classmethod
    def from_dict(cls, data):
        center = tuple(data["center"])
        radius = data["radius"]
        tokens = data["tokens"]
        label = data["label"]
        state = cls(center=center, radius=radius, tokens=tokens, label=label)
        state.incoming_arcs = [Arc.from_dict(arc) for arc in data.get("incoming_arcs", [])]
        state.outgoing_arcs = [Arc.from_dict(arc) for arc in data.get("outgoing_arcs", [])]
        return state

