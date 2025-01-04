from src import cv2, np


def preprocess_image(image, blur=1, canny_threshold=112, dilate_iterations=1, erode_iterations=1):
    if image is None or image.size == 0:
        raise ValueError("Obraz jest pusty lub nie został załadowany poprawnie.")
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    blured = cv2.GaussianBlur(gray, (blur, blur), 1)
    #canny = cv2.Canny(blured, canny_threshold, canny_threshold)
    _, threshHold = cv2.threshold(blured, canny_threshold, 255, cv2.THRESH_BINARY_INV)
    kernel = np.ones((3, 3))
    dilate = cv2.dilate(threshHold, kernel, iterations=dilate_iterations)
    erode = cv2.erode(dilate, kernel, iterations=erode_iterations)
    return erode
