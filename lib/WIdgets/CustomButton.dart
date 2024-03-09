import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.width = double.infinity,
    required this.text,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.onTap,
    this.fontSize = 16,
  });
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final double? width;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Card(
            color: backgroundColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            child: SizedBox(
              width: width,
              child: InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "$text",
                      style: TextStyle(
                        fontSize: fontSize,
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
