// أضف هذا في ملف helper
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

Future<bool> isValidImageUrl(String? url) async {
  if (url == null || url.isEmpty) {
    debugPrint('Image URL is null or empty');
    return false;
  }

  try {
    final response = await http.head(Uri.parse(url));
    final contentType = response.headers['content-type'];
    return response.statusCode == 200 &&
        contentType != null &&
        contentType.startsWith('image/');
  } catch (e) {
    debugPrint('Error validating image URL: $e');
    return false;
  }
}
