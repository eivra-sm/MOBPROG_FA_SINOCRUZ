import 'package:flutter/material.dart';
import 'profile_infos.dart';

const double cardWidth = 429.0;
const double cardPadding = 50.0;
const double cardRadius = 24.0;

const List<Color> cardGradientColors = [
  Color(0xFFA8EB12),
  Color(0xFF26A357),
  Color(0xFF076653),
  Color(0xFF00374E),
  Color.fromARGB(255, 1, 37, 63),
];

class ProfileCard extends StatelessWidget {
  final String name;
  final String course;
  final String motto;

  const ProfileCard({
    super.key,
    required this.name,
    required this.course,
    required this.motto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardRadius),
        gradient: const LinearGradient(
          colors: cardGradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ProfileInfos(
        name: name,
        course: course,
        motto: motto,
      ),
    );
  }
}