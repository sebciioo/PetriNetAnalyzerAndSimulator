from flask import Flask, request, jsonify
import cv2
import threading
import os
import sys


app = Flask(__name__)

@app.route("/")
def hello():
    print("Testuje opencv")
    print(f"Wersja Pythona: {sys.version}")
    print(cv2.__version__)
    files_dir = os.path.join(os.path.dirname(__file__), "data")
    image_path = os.path.join(files_dir, "test.png")
    print("Zraz wczytam obraz")
    image = cv2.imread(image_path)
    cv2.circle(image, (100, 100), 25, 255, thickness=-1)
    print(f"Ścieżka do obrazu: {image_path}")
    if image is None:
        return "Nie znaleziono obrazu w folderze data/", 404
    height, width, channels = image.shape
    return f"Obraz załadowany: Wymiary {width}x{height}, Kanały: {channels}. OpenCV działa poprawnie"


@app.route("/health")
def health_check():
    return "Server is alive", 200

@app.route("/test_post", methods=["POST"])
def test_post():
    """
    Endpoint do testowania żądań POST.
    """
    # Pobierz dane z żądania
    data = request.get_json()
    if not data:
        return jsonify({"error": "No data provided"}), 400

    # Przykładowe przetwarzanie danych
    name = data.get("name", "unknown")
    return jsonify({"message": f"Hello, {name}!", "received_data": data}), 200

def start_server():
    """
    Uruchamia serwer Flask w tle z logiką "fire and forget".
    """
    def run_server():
        # Uruchomienie serwera Flask (bez debugowania, aby uniknąć problemów w środowisku produkcyjnym)
        app.run(host="0.0.0.0", port=5666, debug=False, use_reloader=False)

    # Uruchomienie serwera w osobnym wątku
    thread = threading.Thread(target=run_server)
    thread.daemon = True  # Wątek zakończy się, gdy aplikacja zostanie zamknięta
    thread.start()
    print("Serwer Flask został uruchomiony w tle.")
