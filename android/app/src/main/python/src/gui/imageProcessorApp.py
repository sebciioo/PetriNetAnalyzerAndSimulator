import tkinter as tk
from tkinter import ttk
from PIL import Image, ImageTk
import cv2
import numpy as np
from src.image_processing import load_image, preprocess_image
from src.detection import detect_circle, detect_arrow
from src.detection import find_line
from src.detection import DigitRecognizer
from src.models import PetriNet, Arc, State, Transition
from src.analysis import PetriNetAnalyzer


class ImageProcessorApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Image Processing App")

        # Załaduj obraz
        self.image_path = 'data/example_image18.jpg'
        self.image = load_image(self.image_path)

        # Inicjalizowanie pustej Sieci
        self.PetriNet = PetriNet()

        # Przechowywane oryginał i przetworzony obraz
        self.original_image = self.image
        self.processed_image = preprocess_image(self.image)
        self.copy_image = np.copy(self.original_image)

        # Linie i koła wykryte
        self.circles = None
        self.tokens = None

        # Parametry do przetwarzania obrazu
        self.blur = tk.IntVar(value=1)
        self.canny_threshold = tk.IntVar(value=112)
        self.dilate_iterations = tk.IntVar(value=1)
        self.erode_iterations = tk.IntVar(value=1)

        # Parametry do okręgu
        self.dp = tk.DoubleVar(value=1)
        self.minDist = tk.IntVar(value=8)  # 8
        self.param1 = tk.IntVar(value=100)
        self.param2 = tk.IntVar(value=23)  # 25
        self.minRadius = tk.IntVar(value=10)
        self.maxRadius = tk.IntVar(value=90)  # 130

        # Parametry lini
        self.rho = tk.IntVar(value=1)
        self.threshold = tk.IntVar(value=80)  # 80
        self.minLength = tk.IntVar(value=55)  # 55
        self.maxGap = tk.IntVar(value=25)  # 25

        # Inicjalizacja atrybutów dla obrazów w interfejsie
        self.original_image_label = None
        self.processed_image_label = None

        # UI Layout
        self.setup_ui()
        self.control_frame = None
        self.blur_value_label.config(text=f"{self.blur.get():.1f}")
        self.canny_value_label.config(text=f"{self.canny_threshold.get():.1f}")
        self.dilate_value_label.config(text=f"{self.dilate_iterations.get():.1f}")
        self.erode_value_label.config(text=f"{self.erode_iterations.get():.1f}")
        self.dp_value_label.config(text=f"{self.dp.get():.1f}")
        self.minDist_value_label.config(text=f"{self.minDist.get():.1f}")
        self.param1_value_label.config(text=f"{self.param1.get():.1f}")
        self.param2_value_label.config(text=f"{self.param2.get():.1f}")
        self.minRadius_value_label.config(text=f"{self.minRadius.get():.1f}")
        self.maxRadius_value_label.config(text=f"{self.maxRadius.get():.1f}")
        self.rho_value_label.config(text=f"{self.rho.get():.1f}")
        self.threshold_value_label.config(text=f"{self.threshold.get():.1f}")
        self.minLength_value_label.config(text=f"{self.minLength.get():.1f}")
        self.maxGap_value_label.config(text=f"{self.maxGap.get():.1f}")

        # Initial display
        self.update_image()

    def setup_ui(self):
        # Left Panel - Sliders
        self.control_frame = ttk.Frame(self.root, padding=10)
        self.control_frame.grid(row=0, column=0, sticky="ns")

        ttk.Label(self.control_frame, text="Processing settings", font=("Helvetica", 14, "bold")).grid(row=0, column=0,
                                                                                                       columnspan=2,
                                                                                                       pady=10,
                                                                                                       sticky="w")
        ## BLUAR ##
        ttk.Label(self.control_frame, text="Blur").grid(row=1, column=0, sticky="w")
        blur_slider = ttk.Scale(self.control_frame, from_=1, to=15, variable=self.blur,
                                command=lambda e: self.update_image())
        blur_slider.grid(row=1, column=1, sticky="we")
        self.blur_value_label = ttk.Label(self.control_frame, text=f"{self.blur.get():.1f}")
        self.blur_value_label.grid(row=1, column=2, sticky="w")

        ## CANNY ##
        ttk.Label(self.control_frame, text="Canny Threshold").grid(row=2, column=0, sticky="w")
        canny_slider = ttk.Scale(self.control_frame, from_=10, to=255, variable=self.canny_threshold,
                                 command=lambda e: self.update_image())
        canny_slider.grid(row=2, column=1, sticky="we")
        self.canny_value_label = ttk.Label(self.control_frame, text=f"{self.canny_threshold.get():.1f}")
        self.canny_value_label.grid(row=2, column=2, sticky="w")

        ## DILATE ##
        ttk.Label(self.control_frame, text="Dilate Iterations").grid(row=3, column=0, sticky="w")
        dilate_slider = ttk.Scale(self.control_frame, from_=1, to=5, variable=self.dilate_iterations,
                                  command=lambda e: self.update_image())
        dilate_slider.grid(row=3, column=1, sticky="we")
        self.dilate_value_label = ttk.Label(self.control_frame, text=f"{self.dilate_iterations.get():.1f}")
        self.dilate_value_label.grid(row=3, column=2, sticky="w")

        ## ERODE ##
        ttk.Label(self.control_frame, text="Erode Iterations").grid(row=4, column=0, sticky="w")
        erode_slider = ttk.Scale(self.control_frame, from_=1, to=5, variable=self.erode_iterations,
                                 command=lambda e: self.update_image())
        erode_slider.grid(row=4, column=1, sticky="we")
        self.erode_value_label = ttk.Label(self.control_frame, text=f"{self.erode_iterations.get():.1f}")
        self.erode_value_label.grid(row=4, column=2, sticky="w")

        # Okręgi
        ttk.Label(self.control_frame, text="Circle settings", font=("Helvetica", 14, "bold")).grid(row=5, column=0,
                                                                                                   columnspan=2,
                                                                                                   pady=10,
                                                                                                   sticky="w")
        ## DP ##
        ttk.Label(self.control_frame, text="dp").grid(row=6, column=0, sticky="w")
        dp_slider = ttk.Scale(self.control_frame, from_=1, to=3, variable=self.dp,
                              command=lambda e: self.update_image())
        dp_slider.grid(row=6, column=1, sticky="we")
        self.dp_value_label = ttk.Label(self.control_frame, text=f"{self.dp.get():.1f}")
        self.dp_value_label.grid(row=6, column=2, sticky="w")

        ## MINDIST ##
        ttk.Label(self.control_frame, text="Min-dist").grid(row=7, column=0, sticky="w")
        minDist_slider = ttk.Scale(self.control_frame, from_=5, to=20, variable=self.minDist,
                                   command=lambda e: self.update_image())
        minDist_slider.grid(row=7, column=1, sticky="we")
        self.minDist_value_label = ttk.Label(self.control_frame, text=f"{self.minDist.get():.1f}")
        self.minDist_value_label.grid(row=7, column=2, sticky="w")

        ## PARAM1 ##
        ttk.Label(self.control_frame, text="Param1").grid(row=8, column=0, sticky="w")
        param1_slider = ttk.Scale(self.control_frame, from_=0, to=200, variable=self.param1,
                                  command=lambda e: self.update_image())
        param1_slider.grid(row=8, column=1, sticky="we")
        self.param1_value_label = ttk.Label(self.control_frame, text=f"{self.param1.get():.1f}")
        self.param1_value_label.grid(row=8, column=2, sticky="w")

        ## PARAM2 ##
        ttk.Label(self.control_frame, text="param2").grid(row=9, column=0, sticky="w")
        param2_slider = ttk.Scale(self.control_frame, from_=0, to=200, variable=self.param2,
                                  command=lambda e: self.update_image())
        param2_slider.grid(row=9, column=1, sticky="we")
        self.param2_value_label = ttk.Label(self.control_frame, text=f"{self.param2.get():.1f}")
        self.param2_value_label.grid(row=9, column=2, sticky="w")

        ## MINRADIUS ##
        ttk.Label(self.control_frame, text="minRadius").grid(row=10, column=0, sticky="w")
        minRadius_slider = ttk.Scale(self.control_frame, from_=5, to=30, variable=self.minRadius,
                                     command=lambda e: self.update_image())
        minRadius_slider.grid(row=10, column=1, sticky="we")
        self.minRadius_value_label = ttk.Label(self.control_frame, text=f"{self.minRadius.get():.1f}")
        self.minRadius_value_label.grid(row=10, column=2, sticky="w")

        ## MAXRADIUS ##
        ttk.Label(self.control_frame, text="maxRadius").grid(row=11, column=0, sticky="w")
        maxRadius_slider = ttk.Scale(self.control_frame, from_=100, to=300, variable=self.maxRadius,
                                     command=lambda e: self.update_image())
        maxRadius_slider.grid(row=11, column=1, sticky="we")
        self.maxRadius_value_label = ttk.Label(self.control_frame, text=f"{self.maxRadius.get():.1f}")
        self.maxRadius_value_label.grid(row=11, column=2, sticky="w")

        # Linia
        ttk.Label(self.control_frame, text="Line settings", font=("Helvetica", 14, "bold")).grid(row=12, column=0,
                                                                                                 columnspan=2,
                                                                                                 pady=10,
                                                                                                 sticky="w")
        ## RHO ##
        ttk.Label(self.control_frame, text="Rho").grid(row=13, column=0, sticky="w")
        rho_slider = ttk.Scale(self.control_frame, from_=1, to=4, variable=self.rho,
                               command=lambda e: self.update_image())
        rho_slider.grid(row=13, column=1, sticky="we")
        self.rho_value_label = ttk.Label(self.control_frame, text=f"{self.rho.get():.1f}")
        self.rho_value_label.grid(row=13, column=2, sticky="w")

        ## threshold ##
        ttk.Label(self.control_frame, text="Threshold").grid(row=14, column=0, sticky="w")
        threshold_slider = ttk.Scale(self.control_frame, from_=30, to=100, variable=self.threshold,
                                     command=lambda e: self.update_image())
        threshold_slider.grid(row=14, column=1, sticky="we")
        self.threshold_value_label = ttk.Label(self.control_frame, text=f"{self.threshold.get():.1f}")
        self.threshold_value_label.grid(row=14, column=2, sticky="w")

        ## minLength ##
        ttk.Label(self.control_frame, text="MinLength").grid(row=15, column=0, sticky="w")
        minLength_slider = ttk.Scale(self.control_frame, from_=30, to=100, variable=self.minLength,
                                     command=lambda e: self.update_image())
        minLength_slider.grid(row=15, column=1, sticky="we")
        self.minLength_value_label = ttk.Label(self.control_frame, text=f"{self.minLength.get():.1f}")
        self.minLength_value_label.grid(row=15, column=2, sticky="w")

        ## maxGap ##
        ttk.Label(self.control_frame, text="MaxGap").grid(row=16, column=0, sticky="w")
        maxGap_slider = ttk.Scale(self.control_frame, from_=10, to=80, variable=self.maxGap,
                                  command=lambda e: self.update_image())
        maxGap_slider.grid(row=16, column=1, sticky="we")
        self.maxGap_value_label = ttk.Label(self.control_frame, text=f"{self.maxGap.get():.1f}")
        self.maxGap_value_label.grid(row=16, column=2, sticky="w")

        # Przycisk do wykrywania okręgów
        # detect_circle_button = ttk.Button(control_frame, text="Detect Circle", command=self.detect_circle)
        # detect_circle_button.grid(row=4, column=0, columnspan=2, pady=5)

        # Przycisk do wykrywania strzałek
        # detect_arrow_button = ttk.Button(control_frame, text="Detect Arrow", command=self.detect_arrow)
        # detect_arrow_button.grid(row=5, column=0, columnspan=2, pady=5)

        # Right Panel - Images
        image_frame = ttk.Frame(self.root, padding=10)
        image_frame.grid(row=0, column=1)

        # Initialize image labels with dummy images to avoid NoneType errors
        dummy_image = ImageTk.PhotoImage(Image.new("RGB", (300, 300), "gray"))

        self.original_image_label = ttk.Label(image_frame, image=dummy_image)
        self.original_image_label.image = dummy_image  # Keep reference to avoid GC
        self.original_image_label.grid(row=0, column=0, padx=10, pady=10)

        self.processed_image_label = ttk.Label(image_frame, image=dummy_image)
        self.processed_image_label.image = dummy_image  # Keep reference to avoid GC
        self.processed_image_label.grid(row=0, column=1, padx=10, pady=10)

    def label_update(self):
        self.blur_value_label.config(text=f"{self.blur.get():.1f}")
        self.canny_value_label.config(text=f"{self.canny_threshold.get():.1f}")
        self.dilate_value_label.config(text=f"{self.dilate_iterations.get():.1f}")
        self.erode_value_label.config(text=f"{self.erode_iterations.get():.1f}")
        self.dp_value_label.config(text=f"{self.dp.get():.1f}")
        self.minDist_value_label.config(text=f"{self.minDist.get():.1f}")
        self.param1_value_label.config(text=f"{self.param1.get():.1f}")
        self.param2_value_label.config(text=f"{self.param2.get():.1f}")
        self.minRadius_value_label.config(text=f"{self.minRadius.get():.1f}")
        self.maxRadius_value_label.config(text=f"{self.maxRadius.get():.1f}")
        self.rho_value_label.config(text=f"{self.rho.get():.1f}")
        self.threshold_value_label.config(text=f"{self.threshold.get():.1f}")
        self.minLength_value_label.config(text=f"{self.minLength.get():.1f}")
        self.maxGap_value_label.config(text=f"{self.maxGap.get():.1f}")

    def update_image(self):
        self.PetriNet = PetriNet()
        # Pobierz wartości z suwaków
        blur = int(self.blur.get())
        if blur % 2 == 0:
            blur += 1
        canny_threshold = int(self.canny_threshold.get())
        dilate_iterations = int(self.dilate_iterations.get())
        erode_iterations = int(self.erode_iterations.get())

        self.processed_image = preprocess_image(
            self.original_image, blur, canny_threshold, dilate_iterations, erode_iterations
        )

        # Wyświetl obrazy
        self.label_update()
        self.detect_circle()
        self.detect_arrow()
        self.detect_token()

        print(f"Stany {len(self.PetriNet.states)}")
        for state in self.PetriNet.states:
            print(state)
        print(f"Tranzycje {len(self.PetriNet.transitions)}")
        for transition in self.PetriNet.transitions:
            print(transition)
        print(f"Strzałki {len(self.PetriNet.arcs)}")
        petriNetAnalyzer = PetriNetAnalyzer(self.PetriNet)
        #petriNetAnalyzer.fire(self.PetriNet.transitions[1])
        #print(petriNetAnalyzer.get_marking())
        #isReversible = petriNetAnalyzer.is_reversible()
        #print(f"Reversible: {isReversible}")
        #print(123)
        self.display_images()

    def detect_circle(self):
        # Wykrywanie okręgów
        dp = int(self.dp.get())
        minDist = int(self.minDist.get())
        param1 = int(self.param1.get())
        param2 = int(self.param2.get())
        minRadius = int(self.minRadius.get())
        maxRadius = int(self.maxRadius.get())
        self.copy_image = np.copy(self.original_image)
        self.circles = detect_circle(self.processed_image, dp, minDist, param1, param2, minRadius, maxRadius)
        if self.circles is not None:
            circles = np.uint16(np.around(self.circles))
            for i in circles[0, :]:
                center = (i[0], i[1])
                radius = i[2]
                cv2.circle(self.copy_image, center, 1, (0, 100, 100), 3)
                cv2.circle(self.copy_image, center, radius, (255, 0, 255), 3)
                # Dodajmy znalezione okręgi do naszej Sieci
                state = State(center=center, radius=radius)
                self.PetriNet.add_state(state)

    def detect_arrow(self):
        rho = int(self.rho.get())
        threshold = int(self.threshold.get())
        minLength = int(self.minLength.get())
        maxGap = int(self.maxGap.get())
        linesP = find_line(self.processed_image, self.PetriNet.states, rho, threshold, minLength, maxGap)
        arrows = []
        transitions = []
        if linesP is not None:
            arrows, transitions = detect_arrow(linesP, self.copy_image, self.PetriNet.states)

        # Przypiszmy odpowiednie linie do strzałek oraz tranzycji z uwzględniem gdzie jest ich początek - grot
        # a gdzie jest ich koniec brak gortu
        for transition in transitions:
            start_point = tuple(transition[0][:2])
            end_point = tuple(transition[0][2:])
            transition = Transition(start_point, end_point)
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

        # self.display_images()

    def detect_token(self):
        model_path = 'data/mnist_cnn_model.h5'
        try:
            recognizer = DigitRecognizer(model_path)
            print(f"Model wczytano poprawnie: {model_path}")
        except OSError as e:
            print(f"Błąd podczas wczytywania modelu: {e}")
            exit(1)
        tokens = recognizer.blob_detection(self.processed_image, self.copy_image)
        for circle in self.PetriNet.states:
            if tokens is not None:
                circle.assign_tokens(tokens)
            if circle.tokens == 0:
                cropped_circle = recognizer.extract_circle_region(self.processed_image, circle)
                digit = recognizer.analyze_and_predict_digit(cropped_circle, self.processed_image, self.copy_image)
                if digit is not None:
                    circle.tokens = digit

    def display_images(self, copy_image=None, processed_image=None):
        if copy_image is None:
            copy_image = self.copy_image
        if processed_image is None:
            processed_image = self.processed_image

        # Konwertuj obraz oryginalny
        original_img_pil = Image.fromarray(cv2.cvtColor(copy_image, cv2.COLOR_BGR2RGB))
        original_img_tk = ImageTk.PhotoImage(original_img_pil)

        # Konfiguracja original_image_label
        self.original_image_label.configure(image=original_img_tk)
        self.original_image_label.image = original_img_tk  # Keep reference to avoid GC

        # Konwertuj obraz przetworzony
        processed_img_pil = Image.fromarray(processed_image)
        processed_img_tk = ImageTk.PhotoImage(processed_img_pil)

        # Konfiguracja processed_image_label
        self.processed_image_label.configure(image=processed_img_tk)
        self.processed_image_label.image = processed_img_tk  # Keep reference to avoid GC
