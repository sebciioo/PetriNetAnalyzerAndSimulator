import 'package:flutter/material.dart';

void showEmptyNetDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Twoja sieć jest pusta!"),
      content: const Text("Dodaj elementy, aby przejść do trybu symulacji."),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}
