import 'package:flutter/material.dart';

enum ReadingStatus {
  wantToRead,
  reading,
  finished,
}

const genreIcons = {
  'Fiction': Icons.auto_awesome,
  'Non-fiction': Icons.article,
  'Fantasy': Icons.castle,
  'Biography': Icons.person,
  'Mystery': Icons.search,
  'Romance': Icons.favorite,
  'Science Fiction': Icons.rocket_launch,
};

class Book {
  final String title;
  final String author;
  final int pages;
  final int rating;
  final String genre;
  ReadingStatus status;

  Book({
    required this.title,
    required this.author,
    required this.pages,
    required this.rating,
    required this.genre,
    required this.status,
  });
}

