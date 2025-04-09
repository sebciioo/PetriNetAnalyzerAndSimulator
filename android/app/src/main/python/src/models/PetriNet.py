import json
from src.models import State, Transition, Arc
from src.analysis import PetriNetAnalyzer
import copy


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

        # Właściwości analizy (domyślnie None, ustawiane po wywołaniu analyze())
        self.is_safe = None
        self.is_bounded = None
        self.is_pure = None
        self.is_connected = None
        self.is_interrupted = None

    def add_state(self, state):
        self.states.append(state)

    def add_arc(self, arc):
        self.arcs.append(arc)

    def add_transition(self, transition):
        self.transitions.append(transition)

    def analyze(self):
        """
        Tworzy `PetriNetAnalyzer`, analizuje sieć i zapisuje wyniki.
        """
        analyzer = PetriNetAnalyzer(copy.deepcopy(self))
        self.is_interrupted = analyzer.interrupted
        self.is_safe = analyzer.safe()
        self.is_bounded = int(analyzer.bounded()) if analyzer.bounded() is not False else False
        self.is_pure = analyzer.pure()
        self.is_connected = analyzer.connected()



    def to_dict(self):
        states_list = [state.to_dict() for state in self.states]
        transitions_list = [transition.to_dict() for transition in self.transitions]
        arcs_list = [arc.to_dict() for arc in self.arcs]
        petri_net_dict = {
            "states": states_list,
            "transitions": transitions_list,
            "arcs": arcs_list,
            "is_safe": self.is_safe,
            "is_bounded": self.is_bounded,
            "is_pure": self.is_pure,
            "is_connected": self.is_connected,
            "is_interrupted": self.is_interrupted
        }
        return petri_net_dict



    @classmethod
    def from_dict(cls, data):
        """
        Tworzy obiekt PetriNet na podstawie słownika JSON.
        """
        petri_net = cls()
        petri_net.states = [State.from_dict(state) for state in data["states"]]
        petri_net.transitions = [Transition.from_dict(tr) for tr in data["transitions"]]
        petri_net.arcs = [Arc.from_dict(arc) for arc in data["arcs"]] 
        petri_net.is_safe = data["is_safe"]
        petri_net.is_bounded = data["is_bounded"]
        petri_net.is_pure = data["is_pure"]
        petri_net.is_connected = data["is_connected"]
        petri_net.is_interrupted = data["is_interrupted"]
        return petri_net
