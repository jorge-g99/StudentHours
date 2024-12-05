import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_hours/screens/add_entry_screen.dart';

void main() {
  testWidgets('Renderiza os campos principais na tela de adicionar entrada', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AddEntryScreen(),
      ),
    );

    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Hours'), findsOneWidget);
    expect(find.text('Select a Date'), findsOneWidget);
    expect(find.text('Select Document'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });
}
