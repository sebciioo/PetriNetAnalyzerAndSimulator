import 'package:flutter/material.dart';
import 'package:petri_net_front/UI/utils/responsive_constants.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton(
      {required this.label,
      this.icon,
      required this.onPressed,
      required this.backgroundColor,
      required this.textColor,
      this.borderColor,
      this.fontMin = 14,
      this.fontMax = 24,
      this.padding = 16,
      super.key});

  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final double? fontMin;
  final double? fontMax;
  final double? padding;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        side: borderColor != null ? BorderSide(color: borderColor!) : null,
        padding: EdgeInsets.symmetric(vertical: padding!),
      ),
      icon: icon != null
          ? Icon(
              icon,
              color: textColor,
            )
          : null,
      label: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: MediaQuery.sizeOf(context).width < kBreakpointSmall
              ? fontMin
              : fontMax,
          color: textColor,
        ),
      ),
    );
  }
}
