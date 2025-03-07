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
        self.is_live = None
        self.is_bounded = None

    def add_state(self, state):
        self.states.append(state)

    def add_arc(self, arc):
        self.arcs.append(arc)

    def add_transition(self, transition):
        self.transitions.append(transition)

    def analyze(self):
        """
        🔥 Tworzy `PetriNetAnalyzer`, analizuje sieć i zapisuje wyniki.
        """
        print("---------------------------0------------------")
        for state in self.states:
            print(state)
        analyzer = PetriNetAnalyzer(copy.deepcopy(self))
        print("---------------------------1------------------")
        self.is_safe = analyzer.safe()
        print("---------------------------2------------------")
        self.is_live = analyzer.live()
        print("---------------------------3------------------")
        self.is_bounded = int(analyzer.bounded()) if analyzer.bounded() is not False else False
        print("---------------------------4------------------")



    def to_dict(self):
        states_list = [state.to_dict() for state in self.states]
        transitions_list = [transition.to_dict() for transition in self.transitions]
        arcs_list = [arc.to_dict() for arc in self.arcs]
        petri_net_dict = {
            "states": states_list,
            "transitions": transitions_list,
            "arcs": arcs_list,
            "is_safe": self.is_safe,
            "is_live": self.is_live,
            "is_bounded": self.is_bounded,
        }
        return petri_net_dict



    @classmethod
    def from_dict(cls, data):
        """
        Tworzy obiekt PetriNet na podstawie słownika JSON.
        """
        print("-------------------W TUTAJ JSON -------------------------")
        print(json.dumps(data, indent=2))  # 🔥 WYŚWIETLA CAŁY JSON DLA DEBUGU
        
        petri_net = cls()
        
        print("📌 Przekazywane do State.from_dict():")
        petri_net.states = [State.from_dict(state) for state in data["states"]]

        print("📌 Przekazywane do Transition.from_dict():")

        petri_net.transitions = [Transition.from_dict(tr) for tr in data["transitions"]]

        print("📌 Przekazywane do Arc.from_dict():")
        petri_net.arcs = [Arc.from_dict(arc) for arc in data["arcs"]]

        print("📌 Wartości cech:")
        print("🔹 is_safe:", data.get("is_safe", None))
        print("🔹 is_live:", data.get("is_live", None))
        print("🔹 is_bounded:", data.get("is_bounded", None))
        
        petri_net.is_safe = data["is_safe"]
        petri_net.is_live = data["is_live"]
        petri_net.is_bounded = data["is_bounded"]
        return petri_net
