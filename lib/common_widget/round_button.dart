import 'package:flutter/material.dart';

import '../common/colo_extension.dart';

enum RoundButtonType { bgGradient, bgSGradient, textGradient }

class RoundButton extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final double? iconSize;
  final RoundButtonType type;
  final VoidCallback onPressed;
  final double fontSize;
  final double elevation;
  final FontWeight fontWeight;

  const RoundButton(
      {super.key,
      this.title,
      this.icon,
      this.iconSize = 16,
      this.type = RoundButtonType.bgGradient,
      this.fontSize = 16,
      this.elevation = 1,
      this.fontWeight = FontWeight.w700,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: type == RoundButtonType.bgSGradient
                ? TColor.secondaryG
                : TColor.primaryG,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: type == RoundButtonType.bgGradient ||
                  type == RoundButtonType.bgSGradient
              ? const [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 0.5,
                      offset: Offset(0, 0.5))
                ]
              : null),
      child: SizedBox(
        height: 50,
        width: double.maxFinite,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            foregroundColor: TColor.primaryColor1,
            elevation: type == RoundButtonType.bgGradient ||
                    type == RoundButtonType.bgSGradient
                ? 0
                : elevation,
            backgroundColor: type == RoundButtonType.bgGradient ||
                    type == RoundButtonType.bgSGradient
                ? Colors.transparent
                : TColor.white,
          ),
          child: type == RoundButtonType.bgGradient ||
                  type == RoundButtonType.bgSGradient
              ? _buildContent(TColor.white)
              : ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) {
                    return LinearGradient(
                            colors: TColor.primaryG,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight)
                        .createShader(
                            Rect.fromLTRB(0, 0, bounds.width, bounds.height));
                  },
                  child: _buildContent(TColor.primaryColor1),
                ),
        ),
      ),
    );
  }

  Widget _buildContent(Color color) {
    if (icon != null) {
      return Icon(
        icon,
        color: color,
        size: iconSize,
      );
    } else if (title != null) {
      return Text(
        title!,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
