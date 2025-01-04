from src import cv2, np


def detect_circle(image, dp=1, minDist=8, param1=100, param2=23, minRadius=10, maxRadius=90):
    rows = image.shape[0]
    circles = cv2.HoughCircles(image, cv2.HOUGH_GRADIENT, dp, rows / minDist,
                               param1=param1, param2=param2,
                               minRadius=minRadius, maxRadius=maxRadius)
    return circles


def is_line_on_circle(line, circles):
    x1, y1, x2, y2 = line[0]
    for circle in circles[0, :]:
        x_c, y_c, r = circle
        dist = np.abs((y2 - y1) * x_c - (x2 - x1) * y_c + x2 * y1 - x1 * y2) / np.sqrt((y2 - y1) ** 2 + (x2 - x1) ** 2)
        if dist <= r * 0.3:
            return True
    return False
