# PetriMind - simulator and analyzer of Petri Nets

![Logo](1.PNG)

![Petri Net Recognition](2.PNG)

**EN 🇬🇧**
PetriMind is an innovative mobile application designed to aid in the analysis, simulation, and understanding of Petri nets. It combines computer vision techniques, advanced algorithms, and an intuitive user interface to provide a seamless experience for students, researchers, and professionals working with Petri nets.

**PL 🇵🇱**
PetriMind to innowacyjna aplikacja mobilna, która ma pomóc w analizie, symulacji i zrozumieniu sieci Petriego. Łączy techniki przetwarzania obrazu, zaawansowane algorytmy i intuicyjny interfejs użytkownika, zapewniając studentom, badaczom i specjalistom pracującym z sieciami Petriego bezproblemowe korzystanie z nich.

---

**PL 🇵🇱**: Symuluj, analizuj – zrozum sieci Petriego  
**EN 🇬🇧**: Simulate, analyze – understand Petri nets

---

## Spis treści / Table of Contents

- [Opis / Description](#opis--description)
- [Instalacja / Installation](#instalacja--installation)
- [Uruchomienie aplikacji / Running the App](#uruchomienie-aplikacji--running-the-app)
- [Autor / Author](#autor--author)

---

## Opis / Description

**PL 🇵🇱**  
Aplikacja dla osób zapoznających się z tematyką sieci Petriego, która wspomoże naukę i zrozumienie tego zagadnienia. Umożliwia ona:

- wykonanie lub wczytanie zdjęcia sieci Petriego, ekstrakcję jej elementów i przetworzenie do postaci cyfrowej,
- tryb symulacji pozwalający na interaktywne uruchamianie tranzycji i obserwowanie zmian przepływu tokenów,
- analizę sieci poprzez wypisanie jej podstawowych cech behawioralnych oraz strukturalnych,
- tryb edycji umożliwiający dodawanie, usuwanie i przesuwanie elementów sieci.

**EN 🇬🇧**  
An application designed for individuals exploring Petri nets, supporting the learning and understanding of this concept. It allows:

- capturing or loading an image of a Petri net, extracting its elements and converting them into a digital format,
- simulation mode for interactively firing transitions and observing token flow changes,
- network analysis by listing its basic behavioral and structural properties,
- editing mode allowing adding, deleting, and moving network elements.

---

## Instalacja / Installation

1. Przejdź do katalogu projektu / Go to the project directory:

```bash
cd petri-mind

```

2. Pobierz zależności / Fetch dependencies::

```bash
flutter pub get
```

## Uruchomienie aplikacji / Running the App

Aby uruchomić aplikację na emulatorze lub urządzeniu fizycznym / To run the app on an emulator or physical device::

```bash
flutter run
```

Jeśli chcesz wygenerować build na Androida lub iOS / To generate a build for Android or iOS:

```bash
# Android APK
 flutter build apk --release --no-tree-shake-icons
```

## Autor / Author

Sebastian Szydłowski
UMK, Wydział Matematyki i Informatyki / NCU, Faculty of Mathematics and Computer Sciencs
