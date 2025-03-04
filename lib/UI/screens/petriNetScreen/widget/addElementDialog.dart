import 'package:flutter/material.dart';
import 'package:petri_net_front/UI/screens/petriNetScreen/models/PetriNetElementAdder.dart';
import 'package:petri_net_front/data/models/petriNet.dart';

void showAddElementDialog(BuildContext context, PetriNetElementAdder adder) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Wybierz element do dodania"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                adder.selectedElement = States(center: const Offset(0, 0));
                Navigator.of(context).pop();
              },
              child: const Text("🟡 Stan"),
            ),
            ElevatedButton(
              onPressed: () {
                adder.selectedElement = Transition(
                    start: const Offset(0, 0), end: const Offset(0, 0));
                Navigator.of(context).pop();
              },
              child: const Text("🟨 Tranzycja"),
            ),
            ElevatedButton(
              onPressed: () {
                adder.selectedElement =
                    Arc(start: const Offset(0, 0), end: const Offset(0, 0));
                Navigator.of(context).pop();
              },
              child: const Text("➡ Łuk"),
            ),
          ],
        ),
      );
    },
  );
}
