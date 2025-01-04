from src.models import State


class PetriNet:
    def __init__(self):
        """
        Inicjalizuje sieć Petri, która zawiera listy stanów, łuków i tranzycji.

        Parameters:
            states (Sate): tablica stanów
            arcs (Arcs): tablica łuków
            transition (Transition): tablica tranzycji
        """
        self.arcs = []  # Lista stanów (State)
        self.states = []  # Lista łuków (Arc)
        self.transitions = []  # Lista tranzycji (Transition)

    def add_state(self, state):
        self.states.append(state)

    def add_arc(self, arc):
        self.arcs.append(arc)

    def add_transition(self, transition):
        self.transitions.append(transition)

    def to_dict(self):
        return {
            "states": [state.to_dict() for state in self.states],
            "transitions": [transition.to_dict() for transition in self.transitions],
            "arcs": [arc.to_dict() for arc in self.arcs],
        }
