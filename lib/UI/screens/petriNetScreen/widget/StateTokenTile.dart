import 'package:flutter/material.dart';

class StateTokenTile extends StatelessWidget {
  const StateTokenTile({
    super.key,
    required this.label,
    required this.tokens,
    required this.onAdd,
    required this.onRemove,
  });

  final String label;
  final int tokens;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15.0),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, color: Colors.red),
              onPressed: onRemove,
            ),
            Text(
              "$tokens",
              style: const TextStyle(fontSize: 15.0),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.green),
              onPressed: onAdd,
            ),
          ],
        ),
      ],
    );
  }
}
