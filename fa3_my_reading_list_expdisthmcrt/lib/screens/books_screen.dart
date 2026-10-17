import 'package:flutter/material.dart';
import 'package:fa3_my_reading_list_expdisthmcrt/models/book.dart';
import 'package:fa3_my_reading_list_expdisthmcrt/widgets/book_item.dart';
import 'package:fa3_my_reading_list_expdisthmcrt/widgets/reading_chart.dart';
import 'package:fa3_my_reading_list_expdisthmcrt/widgets/summary.dart';
import 'package:fa3_my_reading_list_expdisthmcrt/screens/new_book.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({
    super.key, 
    required this.onToggleTheme, 
    required this.isDarkMode
  });

  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final List<Book> _books = [];

  void _openBookModal() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewBook(addBook: _addBook),
    );
  }

  void _addBook(Book book) {
    setState(() {
      _books.add(book);
    });
  }

  void _updateStatus(Book book, ReadingStatus status) {
    setState(() {
      book.status = status;
    });
  }

  void _deleteBook(Book book) {
    final index = _books.indexOf(book);
    setState(() {
      _books.remove(book);
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('"${book.title}" removed.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() {
                _books.insert(index, book);
              });
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reading List'),
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: "Toggle Theme",
          ),
          IconButton(
            onPressed: _openBookModal,
            icon: const Icon(Icons.add),
            tooltip: "Add Book",
          ),
        ],
      ),
      body: Column(
        children: [
          Summary(books: _books),
          ReadingChart(books: _books),
          Expanded(
            child: _books.isEmpty
                ? const Center(child: Text('Your reading list is empty. Tap + to add!'))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: _books.length,
                    itemBuilder: (context, index) {
                      final book = _books[index];
                      return Dismissible(
                        key: ValueKey(book.title),
                        background: Container(
                          color: Theme.of(context).colorScheme.error.withOpacity(0.4),
                          margin: Theme.of(context).cardTheme.margin,
                        ),
                        onDismissed: (direction) => _deleteBook(book),
                        child: BookItem(
                          book: book,
                          onStatusChanged: (status) => _updateStatus(book, status),
                          onDelete: () => _deleteBook(book),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

