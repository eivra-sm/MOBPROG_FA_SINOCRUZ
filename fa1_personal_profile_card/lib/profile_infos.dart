import 'package:flutter/material.dart';

const double nameFontSize = 30.0;
const double courseFontSize = 16.0;
const double mottoFontSize = 14.0;

const double nameBottomSpacing = 10;
const double courseBottomSpacing = 15;

class ProfileInfos extends StatelessWidget {
  final String name;
  final String course;
  final String motto;

  const ProfileInfos({
    super.key,
    required this.name,
    required this.course,
    required this.motto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: nameFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: nameBottomSpacing),
        Text(
          course,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: courseFontSize,
            color: Colors.white70,
          ),
        ),

        const SizedBox(height: courseBottomSpacing),
        Text(
          motto,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: mottoFontSize,
            fontStyle: FontStyle.italic,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}