import 'package:flutter/material.dart';
import 'profile_infos.dart';
import 'cardprof_design.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

const Color backgroundColor = Color(0xFF669b53);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
       textTheme: GoogleFonts.marcellusTextTheme(),
      ),
    home: const ProfileCardScreen(),
    );
  }
}

class ProfileCardScreen extends StatelessWidget {
  const ProfileCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: const Center(
        child: ProfileCard(
          name: 'ARVIE M. SINOCRUZ',
          course: 'Bachelor of Science in Applied Mathematics with Information Technology',
          motto: '"Memento Mori, Memento Vivere"',
        ),
      ),
    );
  }
}