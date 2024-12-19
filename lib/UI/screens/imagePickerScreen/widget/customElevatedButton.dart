import 'package:flutter/material.dart';
import 'package:petri_net_front/UI/utils/responsive_constants.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton(
      {required this.label,
      required this.icon,
      required this.onPressed,
      required this.backgroundColor,
      required this.textColor,
      this.borderColor,
      super.key});

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        side: borderColor != null ? BorderSide(color: borderColor!) : null,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      icon: Icon(
        icon,
        color: textColor,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize:
              MediaQuery.sizeOf(context).width < kBreakpointSmall ? 14.0 : 24.0,
          color: textColor,
        ),
      ),
    );
  }
}
