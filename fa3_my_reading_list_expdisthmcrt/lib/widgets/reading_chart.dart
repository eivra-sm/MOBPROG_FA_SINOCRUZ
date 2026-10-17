import 'package:flutter/material.dart';
import 'package:fa3_my_reading_list_expdisthmcrt/models/book.dart';

class ReadingChart extends StatelessWidget {
  const ReadingChart({super.key, required this.books});

  final List<Book> books;

  @override
  Widget build(BuildContext context) {
   final counts = [
      books.where((b) => b.status == ReadingStatus.wantToRead).length,
      books.where((b) => b.status == ReadingStatus.reading).length,
      books.where((b) => b.status == ReadingStatus.finished).length,
    ];

    final labels = ['Want to Read', 'Reading', 'Finished Books'];

    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
    ];

    final maxCount = counts.fold<int>(
      0,
      (maximum, count) => count > maximum ? count : maximum,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Books Status Chart', 
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(3, (index) {
                  final count = counts[index];
    
                  final barHeight = maxCount == 0 
                  ? 0.0
                  : 90.0 * (count / maxCount);

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('$count'),
                          const SizedBox(height: 4),
                          Container(
                            width: 20,
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: colors[index],
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(8),
                              )
                            ),
                          ), 
                          const SizedBox(height: 4),
                          Text(labels[index], 
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}