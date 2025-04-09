import cv2
import numpy as np
import tensorflow as tf
from tensorflow.keras.models import load_model
from PIL import Image


class DigitRecognizer:
    def __init__(self, model_path):
        """
        Inicjalizacja klasyfikatora cyfr.
        """
        self.model = tf.lite.Interpreter(model_path=model_path)
        self.model.allocate_tensors()
        self.input_details = self.model.get_input_details()
        self.output_details = self.model.get_output_details()
        self.offset_x = 0
        self.offset_y = 0

    @staticmethod
    def preprocess_circle_image(circle_image):
        """
        Przetwarza obraz wycięty z wnętrza koła, aby był zgodny z wejściem modelu.
        """
        image = cv2.resize(circle_image, (28, 28))
        image = image.astype(np.float32) / 255.0 
        image = np.expand_dims(image, axis=0)  
        image = np.expand_dims(image, axis=-1) 
        return image

    def analyze_and_predict_digit(self, cropped_circle, processed_image, image, pixel_intensity_threshold=20):
        """
        Sprawdzanie intesynowsci pikseli a nastepnie wyrkycie liczby.

        """
        # Sprawdzenie natężenia pikseli
        pixel_intensity = np.sum(cropped_circle > 0)  # Liczba niezerowych pikseli
        if pixel_intensity < pixel_intensity_threshold:
            print("Za mało pikseli do analizy.")
            return None
        processed_image = self.preprocess_circle_image(cropped_circle)
        self.model.set_tensor(self.input_details[0]['index'], processed_image)
        self.model.invoke()  # Uruchamia predykcję
        prediction = self.model.get_tensor(self.output_details[0]['index'])
        return np.argmax(prediction)

    @staticmethod
    def blob_detection(processed_image, image):
        """
        Detekcja blobów
        """
        params = cv2.SimpleBlobDetector_Params()
        params.filterByColor = False
        params.minThreshold = 70  # 70
        params.maxThreshold = 95  # 95
        params.filterByInertia = True
        params.minInertiaRatio = 0.4
        params.blobColor = 0
        params.minArea = 150  # 300
        params.maxArea = 850  # 850
        params.filterByCircularity = True  # True
        params.filterByConvexity = True
        params.minCircularity = 0.4

        detector = cv2.SimpleBlobDetector.create(params)
        keypoints = detector.detect(processed_image)

        if len(keypoints) > 0:
            i = 0
            for kp in keypoints:
                i += 1
                # Przesunięcie współrzędnych keypointów
                adjusted_x = int(kp.pt[0])
                adjusted_y = int(kp.pt[1])
            print(f"Blob wykryty: {len(keypoints)} blobów.")
            return keypoints

    def extract_circle_region(self, image, circle):
        """
        Wycina wnętrze koła z obrazu i zwraca fragment obrazu zawierający największy kontur w kole.

        """
        cx, cy = circle.center
        r = circle.radius
        # Tworzenie maski
        mask = np.zeros_like(image, dtype=np.uint8)
        cv2.circle(mask, (cx, cy), int(r), 255, thickness=-1)
        masked_image = cv2.bitwise_and(image, image, mask=mask)
        # Zawężenie obszaru do środka koła
        inner_margin = int(r * 0.5)
        x1, y1 = max(0, cx - inner_margin), max(0, cy - inner_margin)
        x2, y2 = min(image.shape[1], cx + inner_margin), min(image.shape[0], cy + inner_margin)
        self.offset_x = x1
        self.offset_y = y1
        cropped_circle = masked_image[y1:y2, x1:x2]
        # Kontur
        contours, _ = cv2.findContours(cropped_circle, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        if not contours:
            return cropped_circle
        # Porstokat dla kontura
        largest_contour = max(contours, key=cv2.contourArea)
        x, y, w, h = cv2.boundingRect(largest_contour)
        contour_region = cropped_circle[y:y + h, x:x + w]
        return contour_region
