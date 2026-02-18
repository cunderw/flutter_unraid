import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unraid/utils/app_exception.dart';
import 'package:graphql/client.dart';

void main() {
  group('AppException', () {
    test('creates exception with message', () {
      const exception = AppException('Test error');
      expect(exception.message, 'Test error');
      expect(exception.cause, isNull);
      expect(exception.stackTrace, isNull);
    });

    test('creates exception with cause and stackTrace', () {
      final cause = Exception('Original error');
      final stackTrace = StackTrace.current;
      final exception = AppException(
        'Test error',
        cause: cause,
        stackTrace: stackTrace,
      );

      expect(exception.message, 'Test error');
      expect(exception.cause, cause);
      expect(exception.stackTrace, stackTrace);
    });

    test('toString returns message', () {
      const exception = AppException('Test error');
      expect(exception.toString(), 'Test error');
    });

    group('fromGraphQL', () {
      test('handles NetworkException', () {
        final linkException = NetworkException(
          message: 'Network error',
          uri: Uri.parse('http://test.com'),
        );
        final operationException = OperationException(linkException: linkException);

        final appException = AppException.fromGraphQL(
          operationException,
          operation: 'testOp',
        );

        expect(
          appException.message,
          'Network error during testOp. Check your connection and server address.',
        );
        expect(appException.cause, linkException);
      });

      test('handles ServerException', () {
        final linkException = ServerException(
          parsedResponse: Response(data: null, response: {}),
          originalException: Exception('Server error'),
        );
        final operationException = OperationException(linkException: linkException);

        final appException = AppException.fromGraphQL(
          operationException,
          operation: 'testOp',
        );

        expect(
          appException.message,
          contains('Server returned error'),
        );
        expect(appException.cause, linkException);
      });

      test('handles GraphQL errors', () {
        final graphqlErrors = [
          GraphQLError(message: 'Error 1'),
          GraphQLError(message: 'Error 2'),
        ];
        final operationException = OperationException(
          graphqlErrors: graphqlErrors,
        );

        final appException = AppException.fromGraphQL(
          operationException,
          operation: 'testOp',
        );

        expect(
          appException.message,
          'Error during testOp: Error 1; Error 2',
        );
        expect(appException.cause, operationException);
      });

      test('handles unknown OperationException', () {
        final operationException = OperationException();

        final appException = AppException.fromGraphQL(
          operationException,
          operation: 'testOp',
        );

        expect(
          appException.message,
          'Unexpected error during testOp.',
        );
        expect(appException.cause, operationException);
      });
    });

    group('from', () {
      test('returns same AppException if already an AppException', () {
        const originalException = AppException('Original');
        final result = AppException.from(
          originalException,
          operation: 'testOp',
        );

        expect(result, same(originalException));
      });

      test('converts OperationException to AppException', () {
        final operationException = OperationException(
          graphqlErrors: [GraphQLError(message: 'GraphQL error')],
        );

        final appException = AppException.from(
          operationException,
          operation: 'testOp',
        );

        expect(
          appException.message,
          'Error during testOp: GraphQL error',
        );
      });

      test('converts arbitrary exception to AppException', () {
        final error = Exception('Random error');
        final stackTrace = StackTrace.current;

        final appException = AppException.from(
          error,
          operation: 'testOp',
          stackTrace: stackTrace,
        );

        expect(appException.message, 'Unexpected error during testOp.');
        expect(appException.cause, error);
        expect(appException.stackTrace, stackTrace);
      });
    });
  });
}
