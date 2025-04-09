from src import cv2, np
from src.models import PetriNet, Arc, State, Transition


def find_contours(image):
    contours, hierarchy = cv2.findContours(image, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
    return contours


def find_line(image, circles, rho=1, threshold=80, minLength=55, maxGap=25):
    # Tworzenie maski, która zakrywa koła
    mask = np.ones_like(image, dtype=np.uint8) * 255
    for circle in circles:
        cx, cy = circle.center
        r = circle.radius
        cv2.circle(mask, (int(cx), int(cy)), int(r), (0, 0, 0), thickness=-1)

    # Nałożenie maski na obraz
    masked_image = cv2.bitwise_and(image, mask)

    # Wykrywanie linii na obrazie po nałożeniu maski
    cdstP = np.copy(masked_image)
    linesP = cv2.HoughLinesP(cdstP, rho, np.pi / 180, threshold, None, minLength, maxGap)
    return linesP


def detect_arrow_and_transition(long_lines, image, circles, radius_threshold=30):
    filtered_lines = filter_lines(long_lines)
    draw_lines(filtered_lines, image)

    transitions = find_disconnected_lines(image, circles, filtered_lines)
    lines_not_transitions = find_arrows(filtered_lines, transitions)
    circle_line_connections, lines_between_circle = find_lines_in_net(circles, lines_not_transitions,
                                                                      radius_threshold, transitions, image)

    arrows = create_arrows_from_connections(circle_line_connections)
    arrows += create_arcs_from_circle_lines(lines_between_circle)

    directions = detect_arrow_directions(arrows, image)

    # print(f"Stany {len(circles)}")
    # print(f"Tranzycje {len(transitions)}")
    # print(f"Strzałki {len(arrows)}")
    return directions, transitions


def draw_lines(filtered_lines, image, blue=0, green=255, red=0):
    """
        Rysuje przefiltrowane linie na obrazie.
    """
    if filtered_lines is not None:
        for line in filtered_lines:
            x1, y1, x2, y2 = line[0]
            cv2.line(image, (x1, y1), (x2, y2), (blue, green, red), 2)


def find_lines_in_net(circles, lines, radius_threshold, transitions, image):
    """
       Znajduje linie, które łączą dwa koła lub które łącza koło a trazycję
    """
    lines_between_circle = []
    circle_line_connections = []
    checked_pairs = set()

    for circle in circles:
        # Znajdź pobliskie linie dla bieżącego koła
        nearby_lines = find_nearby_lines(circle, lines)
        for line in nearby_lines:
            x1, y1, x2, y2 = line[0]
            if tuple(line[0]) in checked_pairs:
                continue
            # Znajdź, czy linia łączy się z innym kołem
            connects_two_circles = False
            for other_circle in circles:
                if circle is not other_circle:
                    ocx, ocy = other_circle.center
                    oradius = other_circle.radius
                    if is_line_pointing_to_circle(line[0], other_circle, image):
                        connects_two_circles = True
                        break

            if connects_two_circles:
                # Jeśli linia łączy się z innym kołem, sprawdź przecięcia z tranzycją
                # te linia zawiera w sobie 2 strzałki i trzeba je podzielic na pół
                handle_intersections(line, transitions, lines_between_circle)
            else:
                # Jeśli linia nie łączy się z kołem, sprawdź przecięcie z tranzycją
                # te linia sa juz na pewno strzalkami trzeba znalezc tylko grot
                handle_intersections(line, transitions, circle_line_connections)
            checked_pairs.add(tuple(line[0]))

    return circle_line_connections, lines_between_circle


def handle_intersections(line, transitions, output_list, threshold=20):
    """
    Obsługuje sprawdzanie przecięć linii z tranzycjami oraz dodaje wynik do odpowiedniej listy.
    """
    for other_line in transitions:
        if not np.array_equal(other_line, line):
            intersection = detect_intersection(line[0], other_line[0])
            if intersection:
                ix, iy = intersection
                output_list.append([line[0], (ix, iy)])
                break
            else:
                # Sprawdź tolerancję, jeśli brak rzeczywistego przecięcia
                x1, y1, x2, y2 = line[0]
                ox1, oy1, ox2, oy2 = other_line[0]

                # Znajdź najbliższe punkty między liniami
                p1 = closest_point_on_line(x1, y1, ox1, oy1, ox2, oy2)
                p2 = closest_point_on_line(x2, y2, ox1, oy1, ox2, oy2)

                # Oblicz minimalne odległości między punktami
                distances = [
                    np.linalg.norm(np.array(p1) - np.array((x1, y1))),
                    np.linalg.norm(np.array(p2) - np.array((x2, y2))),
                ]

                min_distance = min(distances)
                if min_distance <= threshold:
                    # Jeśli znaleziono punkt w tolerancji, zwróć najbliższy punkt
                    closest_points = [p1, p2]
                    closest_point = closest_points[distances.index(min_distance)]
                    output_list.append([line[0], (int(closest_point[0]), int(closest_point[1]))])
                    break


def closest_point_on_line(px, py, x1, y1, x2, y2):
    """
    Znajduje najbliższy punkt na odcinku linii (x1, y1)-(x2, y2) do punktu (px, py).
    """
    line_len = np.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)
    if line_len == 0:
        return x1, y1 

    # Wektor linii
    t = max(0, min(1, ((px - x1) * (x2 - x1) + (py - y1) * (y2 - y1)) / (line_len ** 2)))

    # Współrzędne punktu na linii
    closest_x = x1 + t * (x2 - x1)
    closest_y = y1 + t * (y2 - y1)

    return closest_x, closest_y


def create_arrows_from_connections(circle_line_connections):
    """
    Tworzy strzałki na podstawie linii łączących koła z tranzycjami.

    """
    arrows = []

    for line in circle_line_connections:
        line_coordinates = line[0]
        intersection_point = line[1]

        x1, y1, x2, y2 = line_coordinates
        ix, iy = intersection_point

        dist_start = np.sqrt((ix - x1) ** 2 + (iy - y1) ** 2)
        dist_end = np.sqrt((ix - x2) ** 2 + (iy - y2) ** 2)

        if dist_start > dist_end:
            farthest_point = (x1, y1)
            new_line_coordinates = [intersection_point[0], intersection_point[1], farthest_point[0], farthest_point[1]]
        else:
            farthest_point = (x2, y2)
            new_line_coordinates = [farthest_point[0], farthest_point[1], intersection_point[0], intersection_point[1]]

        arrows.append(new_line_coordinates)

    return arrows


def create_arcs_from_circle_lines(lines_between_circle):
    """
       Tworzy dwie strzałki z linii między kołami.

    """
    arrows = []

    for line in lines_between_circle:
        line_coordinates = line[0]
        intersection_point = line[1]

        dx, dy = intersection_point[0] - line_coordinates[0], intersection_point[1] - line_coordinates[1]
        dx2, dy2 = line_coordinates[2] - intersection_point[0], line_coordinates[3] - intersection_point[1]

        first_arrow = [
            int(line_coordinates[0] + dx * 0.95), int(line_coordinates[1] + dy * 0.95),
            line_coordinates[0], line_coordinates[1]
        ]
        second_arrow = [
            line_coordinates[2], line_coordinates[3],
            int(line_coordinates[2] - dx2 * 0.95), int(line_coordinates[3] - dy2 * 0.95)
        ]

        arrows.append(np.array(first_arrow, dtype=object))
        arrows.append(np.array(second_arrow, dtype=object))

    return arrows


def detect_arrow_directions(arrows, image):
    """
      Wykrywa kierunek strzałek, porównując intensywności pikseli na końcach linii.

    """
    directions = []

    if len(image.shape) == 3:
        gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    else:
        gray_image = image

    for arrow in arrows:
        x1, y1, x2, y2 = arrow
        if x1 > x2:
            x1, x2 = x2, x1
            y1, y2 = y2, y1
        elif x1 == x2:
            if y1 > y2:
                x1, x2 = x2, x1
                y1, y2 = y2, y1
        dx, dy = x2 - x1, y2 - y1
        radius = 15

        start_x, start_y = int(x1 + dx * 0.1), int(y1 + dy * 0.1)
        end_x, end_y = int(x1 + dx * 0.9), int(y1 + dy * 0.9)

        mask_start = np.zeros_like(gray_image, dtype=np.uint8)
        cv2.circle(mask_start, (start_x, start_y), radius, (255, 255, 255), -1)
        cv2.line(mask_start, (x1, y1), (x2, y2), (0, 0, 0), thickness=3)
        start_region = cv2.bitwise_and(gray_image, gray_image, mask=mask_start)

        mask_end = np.zeros_like(gray_image, dtype=np.uint8)
        cv2.circle(mask_end, (end_x, end_y), radius, (255, 255, 255), -1)
        cv2.line(mask_end, (x1, y1), (x2, y2), (0, 0, 0), thickness=3)
        end_region = cv2.bitwise_and(gray_image, gray_image, mask=mask_end)

        start_intensity = np.sum(start_region)
        end_intensity = np.sum(end_region)
        if end_intensity > start_intensity:
            # END
            line_with_directions = [(start_x, start_y), (end_x, end_y), (start_x, start_y)]
            directions.append(line_with_directions)
            cv2.circle(image, (start_x, start_y), radius, (0, 0, 255), -1)
            cv2.circle(image, (end_x, end_y), radius, (255, 0, 0), 2)
        else:
            # START
            line_with_directions = [(start_x, start_y), (end_x, end_y), (end_x, end_y)]
            directions.append(line_with_directions)
            cv2.circle(image, (start_x, start_y), radius, (255, 0, 0), 2)
            cv2.circle(image, (end_x, end_y), radius, (0, 0, 255), -1)

    return directions


def detect_intersection(line1, line2):
    """Znajdź punkt przecięcia dwóch linii, jeśli istnieje"""
    x1, y1, x2, y2 = line1
    x3, y3, x4, y4 = line2

    denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
    if denom == 0:
        # Linie są równoległe
        return None  

    px = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / denom
    py = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / denom

    # Sprawdzenie, czy punkt przecięcia leży na obu odcinkach
    if not (min(x1, x2) <= px <= max(x1, x2) and min(y1, y2) <= py <= max(y1, y2)):
        return None
    if not (min(x3, x4) <= px <= max(x3, x4) and min(y3, y4) <= py <= max(y3, y4)):
        return None

    return int(px), int(py)


def is_line_near_circle(circle, line, radius_threshold=80):
    """
    Sprawdza, czy linia znajduje się w pobliżu koła.
    """
    cx, cy = circle.center
    cr = circle.radius
    x1, y1, x2, y2 = line[0]

    # Oblicz dystanse od środka koła do punktów początkowych i końcowych linii
    dist_start = np.sqrt((cx - x1) ** 2 + (cy - y1) ** 2)
    dist_end = np.sqrt((cx - x2) ** 2 + (cy - y2) ** 2)

    # Jeśli dowolny z dystansów jest mniejszy niż radius_threshold, linia jest blisko koła
    return dist_start < radius_threshold or dist_end < radius_threshold


def find_nearby_lines(circle, lines, radius_threshold=80):
    """
    Znajdź linie w pobliżu koła.
    """
    return [line for line in lines if is_line_near_circle(circle, line, radius_threshold)]


def find_disconnected_lines(image, circles, lines, radius_threshold=80):
    """
    Znajdź linie, które nie są połączone z żadnym kołem.
    """
    disconnected_lines = []
    for line in lines:
        # Sprawdź, czy linia jest połączona z dowolnym kołem
        connected = False
        for circle in circles:
            if is_line_near_circle(circle, line, radius_threshold):
                connected = True
                break

        # Jeśli linia nie jest połączona z żadnym kołem, dodaj ją do wyniku
        if not connected:
            x1, y1, x2, y2 = map(int, line[0])
            cv2.line(image, (x1, y1), (x2, y2), (255, 255, 255), 2)
            disconnected_lines.append(line)

    return disconnected_lines


def find_arrows(lines, transitions):
    """
    Znajdź linie, które nie znajdują się w transitions (są potencjalnymi strzałkami).
    """
    # Konwersja do listy, jeśli dane są w formacie numpy array
    if isinstance(lines, np.ndarray):
        lines = [tuple(line[0]) for line in lines]
    else:
        lines = [tuple(line[0]) for line in lines]

    if isinstance(transitions, np.ndarray):
        transitions = [tuple(line[0]) for line in transitions]
    else:
        transitions = [tuple(line[0]) for line in transitions]

    # Znajdź linie, które nie należą do transitions
    arrows = [line for line in lines if line not in transitions]
    return np.array([[list(line)] for line in arrows], dtype=object)


def calculate_angle(line):
    """Oblicza kąt nachylenia linii względem osi poziomej."""
    x1, y1, x2, y2 = line
    return np.degrees(np.arctan2(y2 - y1, x2 - x1))


def line_length(line):
    """Oblicza długość linii."""
    x1, y1, x2, y2 = line
    return np.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)


def lines_overlap_with_tolerance(line1, line2, tolerance=20, num_points=30):
    """
    Sprawdza, czy jakikolwiek punkt z linii1 (podzielonej na num_points) znajduje się na linii2 w granicach tolerancji.
    """
    x1, y1, x2, y2 = line1
    ox1, oy1, ox2, oy2 = line2

    def point_to_line_distance(px, py, lx1, ly1, lx2, ly2):
        """
        Oblicza odległość punktu (px, py) od linii (lx1, ly1)-(lx2, ly2).
        """
        line_len = np.sqrt((lx2 - lx1) ** 2 + (ly2 - ly1) ** 2)
        if line_len == 0:
            return np.sqrt((px - lx1) ** 2 + (py - ly1) ** 2)
        # Projekcja punktu na linię
        t = max(0, min(1, ((px - lx1) * (lx2 - lx1) + (py - ly1) * (ly2 - ly1)) / (line_len ** 2)))
        proj_x = lx1 + t * (lx2 - lx1)
        proj_y = ly1 + t * (ly2 - ly1)
        return np.sqrt((proj_x - px) ** 2 + (proj_y - py) ** 2)

    # Generuj równomiernie rozmieszczone punkty na linii1
    points = [
        (int(x1 + t * (x2 - x1)), int(y1 + t * (y2 - y1)))
        for t in np.linspace(0, 1, 100)
    ]

    # Sprawdź, ile punktów z linii1 znajduje się na linii2
    match_count = sum(
        point_to_line_distance(px, py, ox1, oy1, ox2, oy2) <= tolerance
        for px, py in points
    )

    return match_count >= num_points


def filter_lines(lines, distance_threshold=50, angle_threshold=20, min_length=20):
    """
    Filtruje linie, pozostawiając jedną linię z każdego zgrupowanego obszaru.
    Wybiera najdłuższą linię, gdy linie są w podobnym miejscu.
    """
    if lines is None or len(lines) == 0:
        print("Brak linii wejściowych do filtrowania.")
        return []

    filtered_lines = []

    for line in lines:
        x1, y1, x2, y2 = line[0]
        angle = calculate_angle((x1, y1, x2, y2))
        length = line_length((x1, y1, x2, y2))

        if length < min_length:
            print(f"Pominięto bardzo krótką linię: {line}")
            continue  # Pomijamy bardzo krótkie linie

        duplicate = False
        for idx, fl in enumerate(filtered_lines):
            fx1, fy1, fx2, fy2 = fl[0]
            f_angle = calculate_angle((fx1, fy1, fx2, fy2))
            f_length = line_length((fx1, fy1, fx2, fy2))

            # Oblicz dystanse między końcami linii
            dist_start = np.sqrt((x1 - fx1) ** 2 + (y1 - fy1) ** 2)
            dist_end = np.sqrt((x2 - fx2) ** 2 + (y2 - fy2) ** 2)
            # Oblicz dystanse dla odwróconych końców linii (x1, y1)-(x2, y2) vs (fx2, fy2)-(fx1, fy1)
            dist_reverse_start = np.sqrt((x1 - fx2) ** 2 + (y1 - fy2) ** 2)
            dist_reverse_end = np.sqrt((x2 - fx1) ** 2 + (y2 - fy1) ** 2)
            # Jeśli kąty są podobne i końce (w dowolnej kolejności) są wystarczająco blisko siebie
            if abs(abs(angle) - abs(f_angle)) < angle_threshold and (
                    (dist_start < distance_threshold and dist_end < distance_threshold) or
                    (dist_reverse_start < distance_threshold and dist_reverse_end < distance_threshold)
            ) or abs(abs(angle) - abs(f_angle)) < angle_threshold and lines_overlap_with_tolerance(line[0], fl[0]):
                # Zastąp krótszą linię dłuższą
                if length > f_length:
                    # print(f"Liania1 {line} o kącie {angle}, Liania2 {fl} o kącie {f_angle}")
                    # print(f"Zastąpienie linii {filtered_lines[idx]} dłuższą linią {line}")
                    filtered_lines[idx] = line
                duplicate = True
                break

        if not duplicate:
            filtered_lines.append(line)
            # print(f"Dodano linię: {line}")

    if len(filtered_lines) == 0:
        print("Nie wykryto żadnych linii po filtrowaniu.")
    return filtered_lines


def is_line_pointing_to_circle(line, circle, image, distance_tolerance=30, angle_tolerance=10):
    """
    Sprawdza, czy linia prowadzi w kierunku obszaru koła (nie tylko środka koła).
    """
    x1, y1, x2, y2 = line
    cx, cy = circle.center
    r = circle.radius

    # Oblicz dystanse końców linii od środka koła
    dist_start_to_center = np.sqrt((x1 - cx) ** 2 + (y1 - cy) ** 2)
    dist_end_to_center = np.sqrt((x2 - cx) ** 2 + (y2 - cy) ** 2)

    # Sprawdź, czy którakolwiek z końcówek znajduje się w zasięgu koła (z tolerancją)
    if (
        abs(dist_start_to_center - r) <= distance_tolerance
        or abs(dist_end_to_center - r) <= distance_tolerance
    ):
        # Oblicz wektor linii
        line_vector = np.array([x2 - x1, y2 - y1])

        # Znajdź najbliższy punkt na krawędzi koła względem obu końców linii
        closest_start_point = closest_point_on_circle(x1, y1, cx, cy, r, image)
        closest_end_point = closest_point_on_circle(x2, y2, cx, cy, r, image)

        # Wektory od linii do punktów na krawędzi koła
        to_start_vector = np.array([closest_start_point[0] - x1, closest_start_point[1] - y1])
        to_end_vector = np.array([closest_end_point[0] - x2, closest_end_point[1] - y2])

        # Normalizuj wektory
        line_vector = line_vector / np.linalg.norm(line_vector)
        to_start_vector = to_start_vector / np.linalg.norm(to_start_vector)
        to_end_vector = to_end_vector / np.linalg.norm(to_end_vector)

        # Oblicz kąty między wektorami linii a wektorami prowadzącymi do obszaru koła
        start_angle = np.degrees(np.arccos(np.clip(np.dot(line_vector, to_start_vector), -1.0, 1.0)))
        end_angle = np.degrees(np.arccos(np.clip(np.dot(line_vector, to_end_vector), -1.0, 1.0)))
        # Jeśli jeden z kątów jest w tolerancji, uznaj linię za prowadzącą do koła
        if (start_angle <= angle_tolerance or abs(180 - start_angle) <= angle_tolerance or
                end_angle <= angle_tolerance or abs(180 - end_angle) <= angle_tolerance):
            return True

    return False


def closest_point_on_circle(px, py, cx, cy, r, image):
    """
    Znajduje najbliższy punkt na obwodzie koła względem danego punktu.
    """
    # Wektor od środka koła do punktu
    vector = np.array([px - cx, py - cy])
    vector_length = np.linalg.norm(vector)

    # Skalowanie wektora do promienia koła
    scaled_vector = vector * (r / vector_length)
    closest_x = cx + scaled_vector[0]
    closest_y = cy + scaled_vector[1]
    return int(closest_x), int(closest_y)


