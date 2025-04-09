from src import cv2, np
import os


def load_image(filename, target_size=600, tolerance=20):
    """Ładuje obraz z zadaną ścieżką i dostosowuje rozmiar w zależności od orientacji."""
    image = cv2.imread(filename)

    if image is None:
        raise ValueError(f"Nie udało się załadować obrazu z: {filename}")
    height, width = image.shape[:2]
    if width > height:  # Obraz poziomy
        if not (target_size - tolerance <= width <= target_size + tolerance):
            aspect_ratio = height / width
            target_height = int(target_size * aspect_ratio)
            resized_image = cv2.resize(image, (target_size, target_height), interpolation=cv2.INTER_AREA)
            return resized_image
    else:  # Obraz pionowy
        if not (target_size - tolerance <= height <= target_size + tolerance):
            aspect_ratio = width / height
            target_width = int(target_size * aspect_ratio)
            resized_image = cv2.resize(image, (target_width, target_size), interpolation=cv2.INTER_AREA)
            return resized_image
    return image
