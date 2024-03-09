import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.width,
    required this.lable,
    required this.hint,
    required this.controller,
    this.icon,
    required this.suffix,
    this.onChange,
  });

  final double width;
  final String lable;
  final String hint;
  final TextEditingController controller;
  final Icon? icon;
  final Widget? suffix;
  final void Function(String)? onChange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          child: SizedBox(
            width: width,
            child: TextField(
              enabled: true,
              onChanged: (val) {},
              controller: controller,
              decoration: InputDecoration(
                filled: true,
                prefixIcon: icon,
                suffix: suffix,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: "$hint",
              ),
            ),
          ),
        ),
      ),
    );
  }
}
