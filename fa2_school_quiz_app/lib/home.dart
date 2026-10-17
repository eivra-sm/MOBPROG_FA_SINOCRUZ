import 'package:flutter/material.dart';
import 'package:fa2_school_quiz_app/home_screen.dart';
import 'package:fa2_school_quiz_app/question/questions_screen.dart';
import 'package:fa2_school_quiz_app/result/score_screen.dart';
import 'package:fa2_school_quiz_app/data/quiz_data.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var activeScreen = 'home-screen';

  var finalScore = 0;

  void startQuiz() {
    setState(() {
      activeScreen = 'question-screen';
      finalScore = 0;
    });
  }

  void goHome() {
    setState(() {
      activeScreen = 'home-screen';
    });
  }

  void showResult(int score) {
    setState(() {
      finalScore = score;
      activeScreen = 'result-screen';
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen = HomeScreen(startQuiz);

    if (activeScreen == 'question-screen') {
      currentScreen = QuestionScreen(showResult);
    }

    if (activeScreen == 'result-screen') {
      currentScreen = ResultScreen(
        finalScore,
        quizQuestions.length,
        startQuiz,
        goHome,
      );
    }

    return MaterialApp(
      title: 'Tamaraw Quiz App',
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 11, 70, 28),
        body: Center(
          child: currentScreen,
        ),
      ),
    );
  }
}