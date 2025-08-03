import 'package:flutter/material.dart';
import '../common/colo_extension.dart';

class IconTextButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final Color? iconColor;
  final VoidCallback onPressed;

  const IconTextButton({
    super.key,
    required this.icon,
    this.iconSize = 16,
    this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: iconSize,
        color: iconColor ?? TColor.gray,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}
