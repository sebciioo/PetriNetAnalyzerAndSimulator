import math
from collections import deque, defaultdict
from src.models import PetriNet, State, Transition


class PetriNetAnalyzer:
    def __init__(self, petriNet):
        if petriNet is None:
            raise ValueError("Przekazana sieć Petriego jest None")
        self.petri_net = petriNet
        self.initial_marking = self.get_marking()
        self.coverability_graph = self.compute_coverability_graph()

    def get_marking(self):
        """
        Zwraca aktualny marking (stan tokenów w sieci Petri) jako krotkę (tuple).
        """
        return tuple(state.tokens for state in self.petri_net.states)
    

    def find_state_by_label(self, label):
        """
        Wyszukuje obiekt State na podstawie jego etykiety (label).
        """
        return next((state for state in self.petri_net.states if state.label == label), None)
    

    def find_transition_by_label(self, label):
        """
        Wyszukuje obiekt State na podstawie jego etykiety (label).
        """
        return next((transition for transition in self.petri_net.transitions if transition.label == label), None)


    def can_fire(self, transition):
        """
        Sprawdza, czy tranzycja może być aktywowana.
        """
        for arc in transition.incoming_arcs:
            state = self.find_state_by_label(arc.start_state)
            if state.tokens <= 0:
                return False
        return True

    def fire(self, transition):
        """
        Aktywuje tranzycję (zmienia marking) bezpośrednio w obiektach stanu.
        """
        if self.can_fire(transition):
            # Usuń tokeny z wejściowych stanów
            for arc in transition.incoming_arcs:
                state = self.find_state_by_label(arc.start_state)
                state.tokens -= 1
            # Dodaj tokeny do wyjściowych stanów
            for arc in transition.outgoing_arcs:
                state = self.find_state_by_label(arc.start_state)
                state.tokens += 1

    def set_marking(self, marking):
        """
        Ustawia aktualny marking (stan tokenów) w sieci Petri na podstawie podanego markingu.
        """
        for state, tokens in zip(self.petri_net.states, marking):
            state.tokens = tokens

    def compute_coverability_graph(self, max_nodes=10000, max_depth=1000):
        """
        Buduje graf pokrywalności zgodnie z algorytmem 3.18
        """
        V = {tuple(self.initial_marking)}
        E = set()
        New = deque([tuple(self.initial_marking)])

        depth = 0
        while New and len(V) < max_nodes and depth < max_depth:
            current_marking = New.popleft()

            for transition in self.petri_net.transitions:
                self.set_marking(current_marking)
                if self.can_fire(transition):
                    self.fire(transition)
                    new_marking = list(self.get_marking())
                    for m in V:
                        if all(m[i] <= new_marking[i] for i in range(len(new_marking))):
                            if any(m[i] < new_marking[i] for i in range(len(new_marking))):
                                for i in range(len(new_marking)):
                                    if m[i] < new_marking[i]:
                                        new_marking[i] = math.inf
                                break

                    new_marking = tuple(new_marking)
                    if new_marking not in V:
                        V.add(new_marking)
                        New.append(new_marking)
                    E.add((current_marking, transition, new_marking))
            depth += 1

        self.coverability_graph = {'vertices': V, 'edges': E}
        return self.coverability_graph


    def safe(self):
        """
        Sprawdza, czy sieć Petri jest bezpieczna (safety).
        Sieć jest bezpieczna, jeśli liczba tokenów w żadnym miejscu nie przekracza 1.
        """
        try:
            if "vertices" not in self.coverability_graph:
                print("❌ Błąd: Brak klucza 'vertices' w coverability_graph!")
                return None  # Możesz zwrócić None, jeśli nie można określić

            for marking in self.coverability_graph['vertices']:
                if not isinstance(marking, (list, tuple)):
                    print(f"❌ Błąd: marking ma niepoprawny typ: {type(marking)}, wartość: {marking}")
                    return None
                
                if any(token > 1 or token == float('inf') for token in marking):
                    return False
            return True
        except Exception as e:
            print(f"❌ Błąd w safe(): {e}")
            return None  # Jeśli błąd, zwróć None


    def bounded(self):
        """
        Sprawdza, czy sieć Petri jest ograniczona (bounded) oraz zwraca, przez jaką wartość jest ograniczona.
        Jeśli sieć nie jest ograniczona, zwraca informację, że jest nieograniczona.
        """
        max_bound = 0
        for marking in self.coverability_graph['vertices']:
            for token in marking:
                if token == float('inf'):
                    return False
                max_bound = max(max_bound, token)
        return max_bound
    
    def pure(self):
        """
        Sprawdza, czy sieć Petriego jest pure (czyli nie zawiera self-loopów).
        Przechodzi przez każdy stan i sprawdza, czy ten sam element ma łuki do i z tej samej tranzycji.
        """
        print("Sprawdza czystość");
        for state in self.petri_net.states:
            for out_arc in state.outgoing_arcs:
                transition = out_arc.start_transition
                for in_arc in state.incoming_arcs:
                    if in_arc.start_transition == transition:
                        # Mamy self-loop: stan -> tranzycja -> ten sam stan
                        print("NIE JEST CZYSTA")
                        print(state)
                        print(transition)
                        return False
        print("JEST CZYSTA")
        return True

    def connected(self):
        """
        Sprawdza, czy sieć jest spójna (connected),
        czyli czy istnieje ścieżka nieukierunkowana między każdą parą wierzchołków.
        """
        all_nodes = self.petri_net.states + self.petri_net.transitions

        neighbors = {node: set() for node in all_nodes}
        print("PRzed grafem----------------")
        for node in all_nodes:
            for arc in node.outgoing_arcs + node.incoming_arcs:
                if isinstance(node, State):
                    neighbor = self.find_transition_by_label(arc.start_transition)
                else:
                    neighbor = self.find_state_by_label(arc.start_state)

                if neighbor is not None:
                    neighbors[node].add(neighbor)
                    neighbors[neighbor].add(node)

        print("PRzed przeszukwianiem----------------")
        visited = set()
        stack = [all_nodes[0]]
        while stack:
            current = stack.pop()
            if current not in visited:
                visited.add(current)
                stack.extend(neighbors[current] - visited)

        print("Wszystko git!---------------------")
        return len(visited) == len(all_nodes)


    def display_coverability_graph(self):
        """
        Wyświetla graf pokrywalności w konsoli
        """
        if not self.coverability_graph:
            self.compute_coverability_graph()

        print("\nGraf Pokrywalności:")
        print("Węzły:")
        for vertex in self.coverability_graph['vertices']:
            print(vertex)

        print("\nKrawędzie:")
        for edge in self.coverability_graph['edges']:
            print(f"{edge[0]} --{edge[1].label}--> {edge[2]}")

