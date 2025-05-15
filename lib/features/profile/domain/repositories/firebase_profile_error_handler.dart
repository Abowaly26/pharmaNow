import 'dart:developer';

class FirebaseProfileErrorHandler {
  static void logError(String method, dynamic error) {
    log('Error in $method: ${error.toString()}', name: 'ProfileRepository');
  }
}
