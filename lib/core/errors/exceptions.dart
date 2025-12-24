class CustomException implements Exception {
  final String message;

  CustomException({required this.message});

  @override
  String toString() {
    return message;
  }
}

abstract class Failures {
  final String message;
  Failures(this.message);
}

class ServerFailure extends Failures {
  ServerFailure(super.message);
}

class RequiresRecentLoginException implements Exception {
  final String message;
  RequiresRecentLoginException(this.message);
}
