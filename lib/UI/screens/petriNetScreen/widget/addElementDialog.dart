import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petri_net_front/UI/screens/petriNetScreen/models/PetriNetElementAdder.dart';
import 'package:petri_net_front/data/models/petriNet.dart';
import 'package:petri_net_front/state/providers/adderState.dart';

void showAddElementDialog(
    BuildContext context, PetriNetElementAdder adder, WidgetRef ref) {
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
                ref.read(petriNetAdderProvider.notifier).updateSelectedElement(
                      States(center: const Offset(0, 0)),
                    );
                Navigator.of(context).pop();
              },
              child: const Text("🟡 Stan"),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(petriNetAdderProvider.notifier).updateSelectedElement(
                      Transition(
                          start: const Offset(0, 0), end: const Offset(0, 0)),
                    );

                Navigator.of(context).pop();
              },
              child: const Text("🟨 Tranzycja"),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(petriNetAdderProvider.notifier).updateSelectedElement(
                      Arc(start: const Offset(0, 0), end: const Offset(0, 0)),
                    );

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
