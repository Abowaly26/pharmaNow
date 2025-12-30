import 'package:flutter/material.dart';

/// A widget that highlights matching text within a string using RichText and TextSpan
/// Supports case-insensitive matching with multiple occurrences highlighting
class HighlightText extends StatelessWidget {
  /// The full text to display
  final String text;
  
  /// The search term to highlight
  final String highlightTerm;
  
  /// Style for the normal text (non-highlighted)
  final TextStyle? textStyle;
  
  /// Style for the highlighted text
  final TextStyle? highlightStyle;
  
  /// Whether to ignore case when matching (default: true)
  final bool caseSensitive;
  
  /// How many lines the text can span
  final int? maxLines;
  
  /// How visual overflow should be handled
  final TextOverflow? overflow;
  
  const HighlightText({
    super.key,
    required this.text,
    required this.highlightTerm,
    this.textStyle,
    this.highlightStyle,
    this.caseSensitive = false,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    // If no highlight term is provided, return the text as is
    if (highlightTerm.isEmpty) {
      return Text(
        text,
        style: textStyle,
        maxLines: maxLines,
        overflow: overflow,
      );
    }
    
    // Determine the text to match against based on case sensitivity
    final searchText = caseSensitive ? text : text.toLowerCase();
    final searchTerm = caseSensitive ? highlightTerm : highlightTerm.toLowerCase();
    
    // Find all matches of the search term in the text
    final matches = _findAllMatches(searchText, searchTerm);
    
    // Build the text spans
    final textSpans = _buildTextSpans(matches, text);
    
    return Text.rich(
      TextSpan(
        style: textStyle,
        children: textSpans,
      ),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
  
  /// Find all occurrences of the search term in the text
  List<TextMatch> _findAllMatches(String searchText, String searchTerm) {
    final matches = <TextMatch>[];
    
    if (searchTerm.isEmpty) return matches;
    
    var start = 0;
    while (start < searchText.length) {
      final index = searchText.indexOf(searchTerm, start);
      if (index == -1) break;
      
      matches.add(TextMatch(start: index, length: searchTerm.length));
      start = index + searchTerm.length;
    }
    
    return matches;
  }
  
  /// Build text spans with highlighted and normal segments
  List<InlineSpan> _buildTextSpans(List<TextMatch> matches, String originalText) {
    if (matches.isEmpty) {
      // No matches found, return the original text as normal text
      return [TextSpan(text: originalText, style: textStyle)];
    }
    
    final spans = <InlineSpan>[];
    var currentIndex = 0;
    
    for (final match in matches) {
      // Add the text before the match (if any)
      if (match.start > currentIndex) {
        spans.add(
          TextSpan(
            text: originalText.substring(currentIndex, match.start),
            style: textStyle,
          ),
        );
      }
      
      // Add the highlighted match
      spans.add(
        TextSpan(
          text: originalText.substring(match.start, match.start + match.length),
          style: highlightStyle ??
              (textStyle?.copyWith(
                color: Colors.blue, // Using a blue color for highlighting
                fontWeight: FontWeight.w500, // Medium weight font
              ) ?? const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              )),
        ),
      );
      
      currentIndex = match.start + match.length;
    }
    
    // Add any remaining text after the last match
    if (currentIndex < originalText.length) {
      spans.add(
        TextSpan(
          text: originalText.substring(currentIndex),
          style: textStyle,
        ),
      );
    }
    
    return spans;
  }
}

/// Represents a match of text with its position and length
class TextMatch {
  final int start;
  final int length;
  
  const TextMatch({required this.start, required this.length});
}