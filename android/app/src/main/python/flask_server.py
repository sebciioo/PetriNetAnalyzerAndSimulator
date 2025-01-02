from flask import Flask, request, jsonify
import threading

app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello, Flask from Android!"

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
