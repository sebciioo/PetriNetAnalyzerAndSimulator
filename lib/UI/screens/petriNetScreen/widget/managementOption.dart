import 'package:flutter/material.dart';
import 'package:petri_net_front/data/models/petriNet.dart';
import 'package:petri_net_front/UI/screens/petriNetScreen/widget/StateTokenTile.dart';

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
      ExpansionTile(
        title: const Text(
          "Zmień ilość tokenów",
          style: TextStyle(
            color: Color(0xFF212121),
            fontWeight: FontWeight.bold,
          ),
        ),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(left: 10),
        trailing: const Padding(
          padding: EdgeInsets.only(right: 0.0),
          child: Icon(
            Icons.expand_more,
            color: Colors.blue,
            size: 24.0,
          ),
        ),
        children: widget.petriNet.states.map((state) {
          return StateTokenTile(
            label: "Stan${state.label.toString().substring(1, 2)}",
            tokens: state.tokens,
            onAdd: () {
              setState(() {
                state.tokens++;
              });
            },
            onRemove: () {
              if (state.tokens > 0) {
                setState(() {
                  state.tokens--;
                });
              }
            },
          );
        }).toList(),
      ),
      // Tile 2: Dodaj/usuń stany
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
    ]);
  }
}
