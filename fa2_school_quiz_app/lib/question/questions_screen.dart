import 'package:flutter/material.dart';
import 'package:fa2_school_quiz_app/commons/styled_button.dart';
import 'package:fa2_school_quiz_app/commons/styled_text.dart';
import 'package:fa2_school_quiz_app/data/quiz_data.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen(this.showResult, {super.key});

  final void Function(int) showResult;

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  var questionIndex = 0;
  var score = 0;

  late List shuffledQuestions;

  @override
  void initState() {
    super.initState();

    shuffledQuestions =[...quizQuestions];
    shuffledQuestions.shuffle();
  }

  void answerQuestion(String answer) {
    if (answer == shuffledQuestions[questionIndex].correctAnswer) {
      score++;
    }

    if (questionIndex == shuffledQuestions.length - 1) {
      widget.showResult(score);
    } else {
      setState(() {
        questionIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = shuffledQuestions[questionIndex];

    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 15,
          children: [
            StyledText(
              'Question ${questionIndex + 1}',
              20,
              color: Colors.amber,
            ),

            StyledText(
              currentQuestion.text,
              28,
              color: Colors.lightGreenAccent,
            ),

            ...currentQuestion.answers.map(
              (answer) => SizedBox(
                width: 250,
                child: StyledButton(
                  text: answer,
                  onPressed: () {
                    answerQuestion(answer);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}