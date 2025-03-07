import math
from collections import deque, defaultdict
from src.models import PetriNet


class PetriNetAnalyzer:
    def __init__(self, petriNet):
        if petriNet is None:
            raise ValueError("Przekazana sieć Petriego jest None")
        
        # Sprawdź, czy wszystkie stany mają poprawne atrybuty
        for state in petriNet.states:
            if state is None:
                raise ValueError("Jeden ze stanów w sieci jest None")
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

    def reversible(self):
        """
        Sprawdza, czy graf pokrywalności jest reversible
        """
        if not self.coverability_graph:
            self.compute_coverability_graph()

        initial_marking = tuple(self.initial_marking)
        reachable_from_all = set()

        # Sprawdź, czy z każdego węzła można dojść do stanu początkowego
        for marking in self.coverability_graph['vertices']:
            visited = set()
            to_visit = deque([marking])

            while to_visit:
                current = to_visit.popleft()
                visited.add(current)

                if current == initial_marking:
                    reachable_from_all.add(marking)
                    break

                # Przejrzyj wszystkie krawędzie, aby znaleźć dostępne przejścia
                for edge in self.coverability_graph['edges']:
                    if edge[0] == current and edge[2] not in visited:
                        to_visit.append(edge[2])

        # Sieć jest reversible, jeśli z każdego węzła można dojść do stanu początkowego
        return len(reachable_from_all) == len(self.coverability_graph['vertices'])

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

    def find_cycles(self):
        """
        Znajduje wszystkie cykle w grafie pokrywalności i zwraca zbiór tranzycji, które należą do co najmniej jednego cyklu.
        """
        adjacency_list = defaultdict(list)
        all_cycles = set()

        # Budowanie listy sąsiedztwa dla grafu pokrywalności
        for edge in self.coverability_graph['edges']:
            start, transition, end = edge
            adjacency_list[start].append((end, transition))

        visited = set()
        path = []
        transition_path = []

        def dfs(node, start_node):
            """Przeszukiwanie w głąb w poszukiwaniu cykli."""
            if node in path:
                # Jeśli znaleziono cykl, zapisujemy go
                cycle_start = path.index(node)
                cycle_transitions = transition_path[cycle_start:]
                all_cycles.update(cycle_transitions)
                return

            # Oznaczamy wierzchołek jako odwiedzony na bieżącej ścieżce
            path.append(node)

            for neighbor, transition in adjacency_list[node]:
                transition_path.append(transition)
                dfs(neighbor, start_node)
                transition_path.pop()

            # Po wyjściu z DFS usuwamy wierzchołek z bieżącej ścieżki
            path.pop()

        # Uruchamiamy DFS dla każdego wierzchołka
        for vertex in self.coverability_graph['vertices']:
            if vertex not in visited:
                dfs(vertex, vertex)

        return all_cycles

    def live(self):
        """
        Sprawdza, czy sieć Petri jest live.
        """
        cycle_transitions = self.find_cycles()
        all_transitions = {t for t in self.petri_net.transitions}
        is_live = cycle_transitions == all_transitions
        return is_live

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

