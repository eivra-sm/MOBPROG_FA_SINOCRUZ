import 'package:flutter/material.dart';
import 'package:fa2_school_quiz_app/commons/styled_button.dart';
import 'package:fa2_school_quiz_app/commons/styled_text.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen(
    this.score,
    this.totalQuestions,
    this.restartQuiz,
    this.goHome, {
    super.key,
  });

  final int score;
  final int totalQuestions;
  final void Function() restartQuiz;
  final void Function() goHome;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 15,
          children: [
            StyledText(
              'Quiz Complete!',
              30,
              color: Colors.amber,
            ),

            StyledText(
              'You got $score out of $totalQuestions correct!',
              22,
              color: Colors.white,
            ),

            const SizedBox(height: 10),

            StyledButton(
              text: 'Restart',
              onPressed: restartQuiz,
            ),

            StyledButton(
              text: 'Exit',
              onPressed: goHome,
            ),
          ],
        ),
      ),
    );
  }
}