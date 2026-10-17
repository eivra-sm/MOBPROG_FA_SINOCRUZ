
import 'package:flutter/material.dart';
import 'package:fa3_my_reading_list_expdisthmcrt/models/book.dart';

class BookItem extends StatelessWidget {
  const BookItem({
    super.key,
    required this.book,
    required this.onStatusChanged,
    required this.onDelete,
  });

  final Book book;
  final ValueChanged<ReadingStatus> onStatusChanged;
  final VoidCallback onDelete;

  String get statusLabel {
    switch (book.status) {
      case ReadingStatus.wantToRead:
        return 'Want to Read';
      case ReadingStatus.reading:
        return 'Currently Reading';
      case ReadingStatus.finished:
        return 'Finished';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.menu_book,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text('by ${book.author}'),
                      Text('${book.genre} • ${book.pages} pages'),
                      Text('Rating: ${'★' * book.rating}${'☆' * (5 - book.rating)}'),
                      const SizedBox(height: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Delete book',
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Expanded(child: Text('Reading status')),
                DropdownButton<ReadingStatus>(
                  value: book.status,
                  items: ReadingStatus.values.map((status) {
                    final label = switch (status) {
                      ReadingStatus.wantToRead => 'Want to Read',
                      ReadingStatus.reading => 'Reading',
                      ReadingStatus.finished => 'Finished',
                    };

                    return DropdownMenuItem(
                      value: status,
                      child: Text(label),
                    );
                  }).toList(),
                  onChanged: (status) {
                    if (status != null) {
                      onStatusChanged(status);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
