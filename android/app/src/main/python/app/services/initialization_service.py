import base64
from src.models.PetriNet import PetriNet
from src.detection import detect_circle, detect_arrow_and_transition, DigitRecognizer
import numpy as np
from src.detection import find_line
from src.image_processing import load_image, preprocess_image
from src.models.arc import Arc
from src.models.state import State
from src.models.transition import Transition
import os
from src import cv2


class InitializationService:
    def __init__(self, image):
        # Inicjalizowanie pustej Sieci
        self.PetriNet = PetriNet()
        # Załaduj i przetwórz obraz
        self.image = load_image(image)
        self.processed_image = preprocess_image(self.image)
        self.files_dir = os.path.join(os.path.dirname(__file__), "data")

    def process_image(self):
        """
        Główna funkcja przetwarzania obrazu i budowy sieci Petri.
        """

        self.detect_states()
        self.detect_arrow_with_transition()
        self.detect_token()
        self.clean_invalid_arcs()
        #self.save_image_in_pictures(self.image, "original_image3.png")
        return self.PetriNet
    
    def image_to_base64(self):
        """
        Konwertuje obraz OpenCV (numpy array) na Base64.
        """
        _, buffer = cv2.imencode('.png', self.image)  # Kodowanie do formatu PNG
        return base64.b64encode(buffer).decode('utf-8')  # Konwersja na Base64


    def detect_states(self):
        """
        Dodaje stany (koła) do sieci Petri na podstawie wykrytych okręgów.
        """
        circles = detect_circle(self.processed_image)
        if circles is not None:
            circles = np.uint16(np.around(circles))
            for circle in circles[0, :]:
                center = (circle[0], circle[1])
                radius = circle[2]
                state_label = f"S{len(self.PetriNet.states) + 1}"
                cv2.circle(self.image , center, 1, (0, 100, 100), 3)
                cv2.circle(self.image , center, radius, (255, 0, 255), 3)
                state = State(center=center, radius=radius, label=state_label)
                print(state_label)
                self.PetriNet.add_state(state)

    def detect_arrow_with_transition(self):
        lines = find_line(self.processed_image, self.PetriNet.states)
        if lines is not None:
            arrows, transitions = detect_arrow_and_transition(lines, self.image, self.PetriNet.states)
            # Przypiszmy odpowiednie linie do strzałek oraz tranzycji z uwzględniem gdzie jest ich początek - grot
            # a gdzie jest ich koniec brak gortu
            for transition in transitions:
                start_point = tuple(transition[0][:2])
                end_point = tuple(transition[0][2:])
                transition_label = f"T{len(self.PetriNet.transitions) + 1}"
                transition = Transition(start_point, end_point, label=transition_label)
                self.PetriNet.add_transition(transition)
            for arrow in arrows:
                start_point = arrow[0]
                end_point = arrow[1]
                direction = arrow[2]
                direction_str = ''
                if direction == start_point:
                    direction_str = "start"
                else:
                    direction_str = "end"
                arc = Arc(start_point, end_point, label=None, arrow_position=direction_str)
                self.PetriNet.add_arc(arc)
                for state in self.PetriNet.states:
                    state.associate_arc(arc, state)
                for transition in self.PetriNet.transitions:
                    transition.associate_arc(arc, transition)

    def detect_token(self):
        base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))
        files_dir = os.path.join(base_dir, "data")
        model_path = os.path.join(files_dir, "mnist_cnn_model.tflite")
        try:
            recognizer = DigitRecognizer(model_path)
        except OSError as e:
            print(f"Błąd podczas wczytywania modelu: {e}")
            exit(1)
        tokens = recognizer.blob_detection(self.processed_image, self.image)
        for circle in self.PetriNet.states:
            if tokens is not None:
                circle.assign_tokens(tokens)
            if circle.tokens == 0:
                cropped_circle = recognizer.extract_circle_region(self.processed_image, circle)
                digit = recognizer.analyze_and_predict_digit(cropped_circle, self.processed_image, self.image)
                if digit is not None:
                    circle.tokens = digit

    def clean_invalid_arcs(self):
        """
        Usuwa łuki, które mają None w start_state lub start_transition.
        Aktualizuje również listy incoming_arcs i outgoing_arcs w stanach i tranzycjach.
        """
        valid_arcs = [arc for arc in self.PetriNet.arcs if arc.start_state is not None and arc.start_transition is not None]
        self.PetriNet.arcs = valid_arcs
        for state in self.PetriNet.states:
            state.incoming_arcs = [arc for arc in state.incoming_arcs if arc in valid_arcs ]
            state.outgoing_arcs = [arc for arc in state.outgoing_arcs if arc in valid_arcs ]
        for transition in self.PetriNet.transitions:
            transition.incoming_arcs = [arc for arc in transition.incoming_arcs if arc in valid_arcs ]
            transition.outgoing_arcs = [arc for arc in transition.outgoing_arcs if arc in valid_arcs ]


