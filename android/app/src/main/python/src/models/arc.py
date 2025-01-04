class Arc:
    def __init__(self, start, end, label=None, arrow_position=None):
        """
        Reprezentuje łuk (strzałkę).

        Parameters:
            start (tuple): Punkt początkowy łuku (x1, y1).
            end (tuple): Punkt końcowy łuku (x2, y2).
            label (str, optional): Etykieta łuku (np. "A1").
            arrow_position (str, optional): Pozycja grotu strzałki na łuku ("start" lub "end").
        """
        self.start = start
        self.end = end
        self.label = label
        self.arrow_position = arrow_position  # "start", "end" lub None
        self.start_state = None  # Referencja do stanu (State)
        self.start_transition = None  # Referencja do tranzycji (Transition)

    def __str__(self):
        return (
            f"Arc(start={self.start}, end={self.end}, label={self.label}, "
            f"arrow_position={self.arrow_position}),"
            f"start_state={self.start_state}"
            f"start_transition={self.start_transition}"
        )

    def to_dict(self):
        return {
            "start": [int(coord) for coord in self.start],
            "end": [int(coord) for coord in self.end],
            "label": self.label,
            "arrow_position": self.arrow_position,
        }
