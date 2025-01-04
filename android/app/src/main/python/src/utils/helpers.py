from src import cv2, np


def display_image(image, window_name="Image"):
    """Wyświetla obraz w nowym oknie."""
    cv2.imshow(window_name, image)
    cv2.waitKey(0)
    cv2.destroyAllWindows()
