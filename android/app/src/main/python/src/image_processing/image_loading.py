from src import cv2, np
import os


def load_image(filename, target_width=600, tolerance=20):
    """Ładuje obraz z zadaną ścieżką."""
    image = cv2.imread(filename)

    if image is None:
        raise ValueError(f"Nie udało się załadować obrazu z: {filename}")

    height, width = image.shape[:2]
    print(height, width)
    if width > target_width+tolerance or width > target_width-tolerance:
        print(1213)
        aspect_ratio = height / width
        target_height = int(target_width * aspect_ratio)
        resized_image = cv2.resize(image, (target_width, target_height), interpolation=cv2.INTER_AREA)
        print(target_height, target_width)
        return resized_image
    else:
        return image
