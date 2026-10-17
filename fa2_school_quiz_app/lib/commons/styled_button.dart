import 'package:flutter/material.dart';
import 'package:fa2_school_quiz_app/commons/styled_text.dart';

class StyledButton extends StatelessWidget {
  const StyledButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
  });

  final String text;
  final void Function() onPressed;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: StyledText(
        text,
        20,
        color: const Color.fromARGB(255, 8, 82, 42),
      ),
    );
  }
}