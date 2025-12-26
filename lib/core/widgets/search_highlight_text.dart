import 'package:flutter/material.dart';

/// A widget that highlights matching text within a string using RichText and TextSpan.
///
/// Features:
/// - Case-insensitive matching
/// - Highlights all occurrences
/// - Supports custom text style and highlight style (color, weight, background)
/// - Null-safe and optimized for performance
class SearchHighlightText extends StatelessWidget {
  /// The full text content to display.
  final String text;

  /// The query text to highlight within the [text].
  final String query;

  /// The style for the normal (non-highlighted) text.
  final TextStyle? defaultStyle;

  /// The color of the highlighted text.
  final Color? highlightColor;

  /// The background color of the highlighted text (for the "box" effect).
  final Color? highlightBackgroundColor;

  /// The font weight of the highlighted text.
  final FontWeight? highlightFontWeight;

  /// Whether to ignore case when matching (default: true).
  final bool caseSensitive;

  /// Maximum number of lines for the text.
  final int? maxLines;

  /// How visual overflow should be handled.
  final TextOverflow? overflow;

  const SearchHighlightText({
    super.key,
    required this.text,
    required this.query,
    this.defaultStyle,
    this.highlightColor,
    this.highlightBackgroundColor,
    this.highlightFontWeight,
    this.caseSensitive = false,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(
        text,
        style: defaultStyle,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final String content = text;
    final String searchText = caseSensitive ? content : content.toLowerCase();
    final String enhanceQuery = caseSensitive ? query : query.toLowerCase();

    // If the query is not found, return normal text
    if (!searchText.contains(enhanceQuery)) {
      return Text(
        content,
        style: defaultStyle,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final List<InlineSpan> spans = [];
    int start = 0;
    int indexOfHighlight;

    do {
      indexOfHighlight = searchText.indexOf(enhanceQuery, start);
      if (indexOfHighlight < 0) {
        // No more matches
        break;
      }

      // 1. Add normal text before the match
      if (indexOfHighlight > start) {
        spans.add(TextSpan(
          text: content.substring(start, indexOfHighlight),
          style: defaultStyle,
        ));
      }

      // 2. Add the highlighted text
      // Define highlight style merging with default style
      final TextStyle highlightStyle =
          (defaultStyle ?? const TextStyle()).copyWith(
        color: highlightColor ?? defaultStyle?.color,
        fontWeight: highlightFontWeight ?? FontWeight.w600,
        backgroundColor: highlightBackgroundColor,
      );

      spans.add(TextSpan(
        text: content.substring(
            indexOfHighlight, indexOfHighlight + enhanceQuery.length),
        style: highlightStyle,
      ));

      // Update start position
      start = indexOfHighlight + enhanceQuery.length;
    } while (start < searchText.length);

    // 3. Add remaining text after the last match
    if (start < content.length) {
      spans.add(TextSpan(
        text: content.substring(start),
        style: defaultStyle,
      ));
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: defaultStyle, // Default parent style
      ),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
    );
  }
}
