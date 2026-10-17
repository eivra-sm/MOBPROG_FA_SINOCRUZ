import 'package:flutter/material.dart';
import 'package:fa3_my_reading_list_expdisthmcrt/models/book.dart';

class Summary extends StatelessWidget {
  const Summary({super.key, required this.books});

  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    final genreCounts = <String, int>{};
    for (final book in books) {
      genreCounts[book.genre] = (genreCounts[book.genre] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Genres Summary',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (books.isEmpty)
               Text(
                'No books added yet.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              )
            else
              Wrap(
                spacing: 24,
                runSpacing: 16,
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  _SummaryItem(
                    label: 'Total Books',
                    count: books.length,
                    icon: Icons.menu_book,
                  ),
                  ...genreCounts.entries.map((entry) {
                    return _SummaryItem(
                      label: entry.key,
                      count: entry.value,
                      icon: genreIcons[entry.key] ?? Icons.category,
                    );
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.count,
    required this.icon,
  });

  final String label;
  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

