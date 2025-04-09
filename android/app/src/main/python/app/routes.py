from flask import Blueprint, request, jsonify
from app.services.initialization_service import InitializationService
from src.models.PetriNet import PetriNet
import os
import sys
import cv2
import json


bp = Blueprint('main', __name__)


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
        if initializer.image  is not None:
            image_base64 = initializer.image_to_base64()
        else:
            image_base64 = None
        petri_net_json = petri_net.to_dict()
        petri_net_json["processed_image"] = image_base64
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
        print(f"Błąd: {e}")
        return jsonify({"error": str(e)}), 500
