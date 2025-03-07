from flask import Blueprint, request, jsonify
from app.services.initialization_service import InitializationService
from src.models.PetriNet import PetriNet
import os
import sys
import cv2
import json


bp = Blueprint('main', __name__)

'''
@bp.route('/process', methods=['GET'])
def process_image():
    """
    Przetwarza obraz na podstawie ścieżki podanej jako parametr w żądaniu GET
    i zwraca dane PetriNet.
    """
    image_path = request.args.get('image', None)
    if not image_path:
        return jsonify({"error": "No image path provided"}), 400

    try:
        base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
        files_dir = os.path.join(base_dir, "data")
        image_path_android = os.path.join(files_dir, "example_image13.jpg")
        initializer = InitializationService(image_path_android)
        petri_net = initializer.process_image()
        return jsonify(petri_net.to_dict())
    except FileNotFoundError:
        return jsonify({"error": f"File not found: {image_path_android}"}), 404
    except Exception as e:
        print(e)
        print("Błąd")
        return jsonify({"error": str(e)}), 500
    
'''
@bp.route('/process', methods=['POST'])
def process_image():
    """
    Przetwarza obraz przesłany jako plik w żądaniu POST
    """
    if 'image' not in request.files:
        return jsonify({"error": "No image file provided"}), 400

    file = request.files['image']
    if file.filename == '':
        return jsonify({"error": "Empty filename"}), 400

    try:
        base_dir = os.path.dirname(os.path.abspath(__file__))
        data_dir = os.path.join(base_dir, "data")
        os.makedirs(data_dir, exist_ok=True)
        file_path = os.path.join(data_dir, file.filename)
        file.save(file_path)
        print(file_path)
        initializer = InitializationService(file_path)
        petri_net = initializer.process_image()
        petri_net.analyze()
        petri_net_json = petri_net.to_dict()
        return jsonify(petri_net_json)
    except Exception as e:
        print(e);
        return jsonify({"error": str(e)}), 500


@bp.route('/analyze', methods=['POST'])
def analyze_petri_net():
    """
    Otrzymuje JSON z siecią Petri, wykonuje ponowną analizę i zwraca wyniki.
    """
    try:
        petri_net_json = request.get_json()
        if not petri_net_json:
            return jsonify({"error": "No JSON data provided"}), 400
        petri_net = PetriNet.from_dict(petri_net_json)
        petri_net.analyze()
        updated_petri_net_json = petri_net.to_dict()
        return jsonify(updated_petri_net_json)

    except Exception as e:
        print(f"❌ Błąd: {e}")
        return jsonify({"error": str(e)}), 500


'''
@bp.route("/")
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
'''
