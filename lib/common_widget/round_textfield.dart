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
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: TColor.lightGray,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        // Quan trọng: Hỗ trợ tiếng Việt có dấu
        enableIMEPersonalizedLearning: true,
        autocorrect: false, // Tắt autocorrect để không can thiệp vào dấu
        enableSuggestions: false, // Tắt suggestions để không làm mất dấu
        textInputAction: TextInputAction.next,
        // Đảm bảo text được render đúng
        textAlign: TextAlign.start,
        textDirection: TextDirection.ltr,
        style: TextStyle(
          color: TColor.black,
          fontSize: 15,
          fontFamily: 'Poppins', // Đảm bảo font hỗ trợ tiếng Việt
        ),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: hitText,
          hintStyle: TextStyle(color: TColor.gray, fontSize: 12),
          prefixIcon: Container(
            alignment: Alignment.center,
            width: 20,
            height: 20,
            child: Image.asset(
              icon,
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              color: TColor.gray,
            ),
          ),
          suffixIcon: rigtIcon,
        ),
      ),
    );
  }
}
