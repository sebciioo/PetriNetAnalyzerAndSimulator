import json
import os
import threading
from urllib import request
from app.services.initialization_service import InitializationService

def process_image(image_path):
    """
    Przetwarza obraz przesłany jako plik i zwraca wynik jako JSON (dict).
    
    :param image_path: Ścieżka do pliku obrazu
    :return: Słownik JSON z przetworzonymi danymi.
    """
    if not os.path.exists(image_path):
        return json.dumps({"error": "Plik nie istnieje"})

    try:
        # 🔥 Przetwarzamy obraz
        initializer = InitializationService(image_path)
        petri_net = initializer.process_image()

        return json.dumps(petri_net.to_dict())  # 🔥 Zwracamy JSON
    except Exception as e:
        return json.dumps({"error": str(e)})
