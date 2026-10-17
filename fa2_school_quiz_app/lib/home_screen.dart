import 'package:flutter/material.dart';
import 'package:fa2_school_quiz_app/commons/styled_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen(this.switchScreen, {super.key});

  final void Function() switchScreen;

  void outlinedButtonPressed() {
    switchScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 10,
      children: [
        Image.asset(
          'assets/logo.png',
          width: 400,
          height: 220,
        ),

        SizedBox(height: 10),

        StyledText(
          'Be Brave Students!',
          30, 
          color: Colors.amber,),

        // Main page button
        OutlinedButton.icon(
          onPressed: outlinedButtonPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.amber,),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.play_arrow_sharp),
          label: StyledText(
            'START', 
            15, 
            color: Colors.white,),
        ),
      ],
    );
  }
}
