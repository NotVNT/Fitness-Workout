
import 'package:flutter/material.dart';

import '../common/colo_extension.dart';

class RoundTextField extends StatelessWidget {
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String hitText;
  final String icon;
  final Widget? rigtIcon;
  final bool obscureText;
  final EdgeInsets? margin;

  const RoundTextField({
    Key? key,
    required this.hitText,
    required this.icon,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.margin = const EdgeInsets.symmetric(vertical: 10),
    this.rigtIcon,
  }) : super(key: key);
  
 @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hitText,
        prefixIcon: Image.asset(icon),
      ),
    );
  }
}