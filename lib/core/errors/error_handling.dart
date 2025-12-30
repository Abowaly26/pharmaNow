import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final StackTrace? stackTrace;

  const Failure(this.message, [this.stackTrace]);

  @override
  List<Object?> get props => [message, stackTrace];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.stackTrace]);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.stackTrace]);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.stackTrace]);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message, [super.stackTrace]);
}
