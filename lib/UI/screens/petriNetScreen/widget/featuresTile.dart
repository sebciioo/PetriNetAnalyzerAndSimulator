import 'package:flutter/material.dart';

class FeaturesTile extends StatelessWidget {
  const FeaturesTile({
    super.key,
    required this.title,
    required this.items,
  });
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF212121),
          fontWeight: FontWeight.bold,
        ),
      ),
      tilePadding: EdgeInsets.zero,
      children: items
          .map((item) => ListTile(
                leading:
                    const Icon(Icons.check_circle_outline, color: Colors.white),
                title: Text(
                  item,
                  style: const TextStyle(color: Colors.black),
                ),
                horizontalTitleGap: -3.0,
              ))
          .toList(),
    );
  }
}
