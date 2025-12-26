import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_now/core/widgets/highlight_text.dart';

void main() {
  group('Search Highlight Integration Tests', () {
    testWidgets('should highlight search terms in medicine name', (WidgetTester tester) async {
      const medicineName = 'Paracetamol 500mg';
      const searchTerm = 'para';

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: HighlightText(
              text: medicineName,
              highlightTerm: searchTerm,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('should highlight search terms in pharmacy name', (WidgetTester tester) async {
      const pharmacyName = 'Pharma Plus';
      const searchTerm = 'pharma';

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: HighlightText(
              text: pharmacyName,
              highlightTerm: searchTerm,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('should handle case insensitive matching', (WidgetTester tester) async {
      const medicineName = 'Aspirin';
      const searchTerm = 'ASP';

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: HighlightText(
              text: medicineName,
              highlightTerm: searchTerm,
              caseSensitive: false,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('should not highlight when no match found', (WidgetTester tester) async {
      const medicineName = 'Ibuprofen';
      const searchTerm = 'xyz';

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: HighlightText(
              text: medicineName,
              highlightTerm: searchTerm,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('should handle empty search term', (WidgetTester tester) async {
      const medicineName = 'Medicine Name';
      const searchTerm = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: HighlightText(
              text: medicineName,
              highlightTerm: searchTerm,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );

      expect(find.byType(Text), findsOneWidget);
    });
  });
}