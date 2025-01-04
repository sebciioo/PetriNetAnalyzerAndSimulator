from src.models import PetriNet


class PetriNetAnalyzer:
    def __init__(self, petriNet):
        self.petri_net = petriNet

    def get_marking(self):
        """
        Zwraca aktualny marking (stan tokenów w sieci Petri).
        """
        return [state.tokens for state in self.petri_net.states]

    @staticmethod
    def can_fire(transition):
        """
        Sprawdza, czy tranzycja może być aktywowana.
        """
        for arc in transition.incoming_arcs:
            if arc.start_state.tokens <= 0:
                return False
        return True

    @staticmethod
    def fire(transition):
        """
        Aktywuje tranzycję (zmienia marking).
        """
        if PetriNetAnalyzer.can_fire(transition):
            # Usuń tokeny z wejściowych stanów
            for arc in transition.incoming_arcs:
                arc.start_state.tokens -= 1

            # Dodaj tokeny do wyjściowych stanów
            for arc in transition.outgoing_arcs:
                arc.start_state.tokens += 1

    # ---------- Cechy Strukutralne
    def is_reversible_with_coverability(self):
        """
        Sprawdza, czy sieć Petri jest odwracalna, używając grafu pokrycia.

        Returns:
            bool: True, jeśli sieć Petri jest odwracalna.
        """
        initial_marking = self.get_marking()
        coverability_graph = {tuple(initial_marking): []}
        stack = [initial_marking]

        while stack:
            current_marking = stack.pop()

            for transition in self.petri_net.transitions:
                if self.can_fire(transition):
                    previous_marking = self.get_marking()
                    self.fire(transition)
                    new_marking = self.get_marking()

                    # Jeśli marking jest nowy, dodaj go do grafu
                    if not any(self.covers(existing_marking, new_marking) for existing_marking in coverability_graph):
                        coverability_graph[tuple(new_marking)] = []
                        stack.append(new_marking)
                    else:
                        # Jeśli marking jest pokryty, zastąp odpowiednie miejsca przez "ω"
                        for existing_marking in coverability_graph:
                            if self.covers(existing_marking, new_marking):
                                new_marking = [
                                    "ω" if new_marking[i] > existing_marking[i] else new_marking[i]
                                    for i in range(len(new_marking))
                                ]
                                coverability_graph[tuple(new_marking)] = []

                    # Przywróć stan
                    for state, tokens in zip(self.petri_net.states, previous_marking):
                        state.tokens = tokens

        # Sprawdzenie odwracalności
        for marking in coverability_graph:
            if not self.can_reach_marking(marking, initial_marking):
                return False

        return True

    def covers(self, marking1, marking2):
        """
        Sprawdza, czy marking1 pokrywa marking2 (relacja pokrycia).
        """
        for t1, t2 in zip(marking1, marking2):
            if t1 != "ω" and t1 < t2:
                return False
        return True

    def can_reach_marking(self, start_marking, target_marking):
        """
        Sprawdza, czy marking docelowy jest osiągalny z danego markingu.
        """
        visited = set()
        stack = [start_marking]

        while stack:
            current_marking = stack.pop()

            if tuple(current_marking) == tuple(target_marking):
                return True

            if tuple(current_marking) in visited:
                continue

            visited.add(tuple(current_marking))

            for transition in self.petri_net.transitions:
                if self.can_fire(transition):
                    previous_marking = self.get_marking()
                    self.fire(transition)
                    stack.append(self.get_marking())

                    # Przywróć stan
                    for state, tokens in zip(self.petri_net.states, previous_marking):
                        state.tokens = tokens

        return False

