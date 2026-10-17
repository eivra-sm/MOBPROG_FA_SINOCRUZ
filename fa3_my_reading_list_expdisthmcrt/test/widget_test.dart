// // This is a basic Flutter widget test.
// //
// // To perform an interaction with a widget in your test, use the WidgetTester
// // utility in the flutter_test package. For example, you can send tap and scroll
// // gestures. You can also use WidgetTester to find child widgets in the widget
// // tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';

// import 'package:fa3_my_reading_list_expdisthmcrt/main.dart';

// void main() {
//   testWidgets('Counter increments smoke test', (WidgetTester tester) async {
//     // Build our app and trigger a frame.
//     // await tester.pumpWidget(const MyReadingListApp());

//     // Verify that our counter starts at 0.
//     expect(find.text('0'), findsOneWidget);
//     expect(find.text('1'), findsNothing);

//     // Tap the '+' icon and trigger a frame.
//     await tester.tap(find.byIcon(Icons.add));
//     await tester.pump();

//     // Verify that our counter has incremented.
//     expect(find.text('0'), findsNothing);
//     expect(find.text('1'), findsOneWidget);
//   });
// }
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fa3_my_reading_list_expdisthmcrt/main.dart';

void main() {
  testWidgets('Reading List app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyReadingListApp());

    // Verify that the app loads and displays the AppBar title
    expect(find.text('My Reading List'), findsOneWidget);

    // Verify that the empty state text is displayed initially
    expect(find.text('Your reading list is empty.'), findsOneWidget);
  });
}