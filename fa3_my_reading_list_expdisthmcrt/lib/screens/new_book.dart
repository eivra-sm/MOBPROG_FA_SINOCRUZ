import 'package:flutter/material.dart';
import 'package:fa3_my_reading_list_expdisthmcrt/models/book.dart';

class NewBook extends StatefulWidget {
  const NewBook({
    super.key, 
    required this.addBook, 
  });

  final void Function(Book book) addBook;

  @override
  State<NewBook> createState() => _NewBookState();
}

class _NewBookState extends State<NewBook> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _pagesController = TextEditingController();
  final _ratingController = TextEditingController(text: '3');
  
  final _genres = [
    'Fiction',
    'Non-fiction',
    'Fantasy',
    'Biography',
    'Mystery',
    'Romance',
    'Science Fiction',
  ];

  String _genre = 'Fiction';
  ReadingStatus _status = ReadingStatus.wantToRead;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pagesController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  void _saveBook() {
    if (!_formKey.currentState!.validate()) return;

    final book = Book(
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      pages: int.parse(_pagesController.text.trim()),
      rating: int.parse(_ratingController.text.trim()),
      genre: _genre,
      status: _status,
    );

    widget.addBook(book);
    Navigator.pop(context); 
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 16),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Book Title'),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Please enter the book title.'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Author'),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Please enter the author.'
                        : null,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pagesController,
                      decoration: const InputDecoration(labelText: 'Pages'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final pages = int.tryParse(value ?? '');
                        if (pages == null || pages <= 0) {
                          return 'Must be > 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _ratingController,
                      decoration: const InputDecoration(
                        labelText: 'Rating (1–5)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final rating = int.tryParse(value ?? '');
                        if (rating == null || rating < 1 || rating > 5) {
                          return 'Must be 1-5';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _genre,
                      decoration: const InputDecoration(labelText: 'Genre'),
                      items: _genres.map((genre) {
                        return DropdownMenuItem(
                          value: genre, 
                          child: Row(
                            children: [
                              Icon(
                                genreIcons[genre] ?? Icons.category, 
                                size: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(genre),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _genre = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<ReadingStatus>(
                      value: _status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: ReadingStatus.values.map((status) {
                        final label = switch (status) {
                          ReadingStatus.wantToRead => 'Want to Read',
                          ReadingStatus.reading => 'Reading',
                          ReadingStatus.finished => 'Finished',
                        };
                        return DropdownMenuItem(value: status, child: Text(label));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _status = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _saveBook,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Book'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

