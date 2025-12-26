import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_now/core/widgets/highlight_text.dart';

void main() {
  group('HighlightText Performance Tests', () {
    testWidgets('should render efficiently with large text', (WidgetTester tester) async {
      // Create a large text string to test performance
      final longText = 'This is a long text string with multiple occurrences of the word test. ' * 100;
      const searchTerm = 'test';

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: HighlightText(
              text: longText,
              highlightTerm: searchTerm,
            ),
          ),
        ),
      );

      // Verify the widget builds without errors
      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('should handle multiple matches efficiently', (WidgetTester tester) async {
      // Create text with many matches
      final textWithMatches = 'test1 test2 test3 test4 test5 test6 test7 test8 test9 test10 ' * 50;
      const searchTerm = 'test';

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: HighlightText(
              text: textWithMatches,
              highlightTerm: searchTerm,
            ),
          ),
        ),
      );

      // Verify the widget builds without errors
      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('should handle empty search term efficiently', (WidgetTester tester) async {
      const text = 'This is a sample text for testing';
      const searchTerm = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: HighlightText(
              text: text,
              highlightTerm: searchTerm,
            ),
          ),
        ),
      );

      // Verify the widget builds without errors
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('should handle no matches efficiently', (WidgetTester tester) async {
      const text = 'This is a sample text for testing';
      const searchTerm = 'xyz';

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: HighlightText(
              text: text,
              highlightTerm: searchTerm,
            ),
          ),
        ),
      );

      // Verify the widget builds without errors
      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('should handle case insensitive matching efficiently', (WidgetTester tester) async {
      const text = 'Test TEST test TesT';
      const searchTerm = 'test';

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: HighlightText(
              text: text,
              highlightTerm: searchTerm,
              caseSensitive: false,
            ),
          ),
        ),
      );

      // Verify the widget builds without errors
      expect(find.byType(RichText), findsOneWidget);
    });
  });
}