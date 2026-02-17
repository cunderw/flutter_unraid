import 'package:graphql/client.dart';

/// Application-level exception that wraps underlying errors with
/// user-friendly messages and preserves the original error for logging.
class AppException implements Exception {
  /// A user-facing message describing what went wrong.
  final String message;

  /// The original error for logging/debugging.
  final Object? cause;

  /// The stack trace from the original error, if available.
  final StackTrace? stackTrace;

  const AppException(this.message, {this.cause, this.stackTrace});

  /// Creates an [AppException] from a GraphQL [OperationException].
  factory AppException.fromGraphQL(
    OperationException exception, {
    required String operation,
  }) {
    // Check for link-level errors first (network issues).
    if (exception.linkException != null) {
      final link = exception.linkException!;
      if (link is NetworkException) {
        return AppException(
          'Network error during $operation. Check your connection and server address.',
          cause: link,
        );
      }
      if (link is ServerException) {
        final code = link.statusCode;
        return AppException(
          'Server returned error $code during $operation.',
          cause: link,
        );
      }
      return AppException('Connection error during $operation.', cause: link);
    }

    // Check for GraphQL-level errors.
    if (exception.graphqlErrors.isNotEmpty) {
      final messages = exception.graphqlErrors.map((e) => e.message).join('; ');
      return AppException(
        'Error during $operation: $messages',
        cause: exception,
      );
    }

    return AppException(
      'Unexpected error during $operation.',
      cause: exception,
    );
  }

  /// Creates an [AppException] from any arbitrary error.
  factory AppException.from(
    Object error, {
    required String operation,
    StackTrace? stackTrace,
  }) {
    if (error is AppException) return error;
    if (error is OperationException) {
      return AppException.fromGraphQL(error, operation: operation);
    }
    return AppException(
      'Unexpected error during $operation.',
      cause: error,
      stackTrace: stackTrace,
    );
  }

  @override
  String toString() => message;
}
