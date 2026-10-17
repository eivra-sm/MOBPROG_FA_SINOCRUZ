import 'package:flutter/material.dart';
import 'package:fa3_my_reading_list_expdisthmcrt/screens/books_screen.dart';

var kColorScheme = ColorScheme.fromSeed(
  seedColor: Color.fromARGB(255, 69, 100, 200),
);

var kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: Color.fromARGB(255, 69, 100, 200),
);

void main() {
  runApp(MyReadingListApp());
}

class MyReadingListApp extends StatefulWidget {
  const MyReadingListApp({super.key});

  @override
  State<MyReadingListApp> createState() => _MyReadingListAppState();
}

class _MyReadingListAppState extends State<MyReadingListApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Reading List',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData().copyWith(
        colorScheme: kColorScheme,
        scaffoldBackgroundColor:  Color.fromARGB(255, 235, 215, 162),
        appBarTheme: AppBarTheme().copyWith(
          backgroundColor: kColorScheme.onPrimaryContainer,
          foregroundColor: kColorScheme.primaryContainer,
        ),

        cardTheme: CardThemeData().copyWith(
          margin: EdgeInsets.symmetric(
            horizontal: 12, 
            vertical: 6
          ),
          color: kColorScheme.secondaryContainer,
        ),
      ),
      
      darkTheme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: kDarkColorScheme,
        cardTheme: CardThemeData().copyWith(
          margin: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6
          ),
          color: kDarkColorScheme.secondaryContainer,
        ),
      ),

      home: BooksScreen(
        onToggleTheme: _toggleTheme,
        isDarkMode: _isDarkMode,
      ),
    );
  }
}

