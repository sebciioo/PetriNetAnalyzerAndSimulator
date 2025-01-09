import 'package:flutter/material.dart';
import 'package:petri_net_front/data/models/petriNet.dart';
import 'package:petri_net_front/UI/screens/petriNetScreen/widget/StateTokenTile.dart';
import 'package:defer_pointer/defer_pointer.dart';

class ManagementOption extends StatefulWidget {
  const ManagementOption({super.key, required this.petriNet});
  final PetriNet petriNet;

  @override
  State<StatefulWidget> createState() {
    return _ManagementOption();
  }
}

class _ManagementOption extends State<ManagementOption> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          child: const Text(
            'Dodaj tokeny do stanów zgodnie naciskając + lub usuń naciskając -',
            style: const TextStyle(
              color: Color(0xFF212121),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      // Tile 2: Dodaj/usuń stany
      /*
      ExpansionTile(
        title: const Text(
          "Dodaj/usuń stany",
          style: TextStyle(
            color: Color(0xFF212121),
            fontWeight: FontWeight.bold,
          ),
        ),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(left: 10),
        children: [
          ListTile(
            leading: const Icon(Icons.add_circle, color: Colors.green),
            title: const Text("Dodaj stan"),
            onTap: () {
              // Logika dodawania stanu
            },
          ),
          ListTile(
            leading: const Icon(Icons.remove_circle, color: Colors.red),
            title: const Text("Usuń stan"),
            onTap: () {
              // Logika usuwania stanu
            },
          ),
        ],
      ),
      */
    ]);
  }
}
