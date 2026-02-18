import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unraid/blocs/auth/auth_cubit.dart';
import 'package:flutter_unraid/blocs/auth/auth_state.dart';
import 'package:flutter_unraid/data/repositories/auth_repository.dart';
import 'package:flutter_unraid/graphql/client.dart';
import 'package:graphql/client.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockGraphQLClientManager extends Mock implements GraphQLClientManager {}

class MockGraphQLClient extends Mock implements GraphQLClient {}

class FakeQueryOptions extends Fake implements QueryOptions {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockGraphQLClientManager mockClientManager;
  late MockGraphQLClient mockGraphQLClient;

  setUpAll(() {
    registerFallbackValue(FakeQueryOptions());
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockClientManager = MockGraphQLClientManager();
    mockGraphQLClient = MockGraphQLClient();

    when(() => mockClientManager.client).thenReturn(mockGraphQLClient);
  });

  group('AuthCubit', () {
    test('initial state is AuthInitial', () {
      final cubit = AuthCubit(mockAuthRepository, mockClientManager);
      expect(cubit.state, const AuthInitial());
      cubit.close();
    });

    group('checkAuthStatus', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, Authenticated] when credentials exist and connection succeeds',
        build: () {
          when(() => mockAuthRepository.getCredentials()).thenAnswer(
            (_) async => ({
              'serverUrl': 'http://test.server',
              'apiKey': 'test-api-key',
            }),
          );
          when(() => mockClientManager.configure(
                serverUrl: any(named: 'serverUrl'),
                apiKey: any(named: 'apiKey'),
              )).thenReturn(null);
          when(() => mockGraphQLClient.query(any())).thenAnswer(
            (_) async => QueryResult(
              data: {'test': 'data'},
              source: QueryResultSource.network,
              options: QueryOptions(document: gql('query { test }')),
            ),
          );
          return AuthCubit(mockAuthRepository, mockClientManager);
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [
          const AuthLoading(),
          const Authenticated(serverUrl: 'http://test.server'),
        ],
        verify: (_) {
          verify(() => mockAuthRepository.getCredentials()).called(1);
          verify(() => mockClientManager.configure(
                serverUrl: 'http://test.server',
                apiKey: 'test-api-key',
              )).called(1);
          verify(() => mockGraphQLClient.query(any())).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, Unauthenticated] when credentials exist but connection fails',
        build: () {
          when(() => mockAuthRepository.getCredentials()).thenAnswer(
            (_) async => ({
              'serverUrl': 'http://test.server',
              'apiKey': 'test-api-key',
            }),
          );
          when(() => mockClientManager.configure(
                serverUrl: any(named: 'serverUrl'),
                apiKey: any(named: 'apiKey'),
              )).thenReturn(null);
          when(() => mockClientManager.reset()).thenReturn(null);
          when(() => mockGraphQLClient.query(any())).thenAnswer(
            (_) async => QueryResult(
              data: null,
              source: QueryResultSource.network,
              options: QueryOptions(document: gql('query { test }')),
              exception: OperationException(),
            ),
          );
          return AuthCubit(mockAuthRepository, mockClientManager);
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [
          const AuthLoading(),
          const Unauthenticated(),
        ],
        verify: (_) {
          verify(() => mockAuthRepository.getCredentials()).called(1);
          verify(() => mockClientManager.reset()).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, Unauthenticated] when no credentials exist',
        build: () {
          when(() => mockAuthRepository.getCredentials())
              .thenAnswer((_) async => null);
          return AuthCubit(mockAuthRepository, mockClientManager);
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [
          const AuthLoading(),
          const Unauthenticated(),
        ],
        verify: (_) {
          verify(() => mockAuthRepository.getCredentials()).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, Unauthenticated] when getCredentials throws',
        build: () {
          when(() => mockAuthRepository.getCredentials())
              .thenThrow(Exception('Storage error'));
          return AuthCubit(mockAuthRepository, mockClientManager);
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [
          const AuthLoading(),
          const Unauthenticated(),
        ],
      );
    });

    group('login', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, Authenticated] when login succeeds',
        build: () {
          when(() => mockClientManager.configure(
                serverUrl: any(named: 'serverUrl'),
                apiKey: any(named: 'apiKey'),
              )).thenReturn(null);
          when(() => mockGraphQLClient.query(any())).thenAnswer(
            (_) async => QueryResult(
              data: {'test': 'data'},
              source: QueryResultSource.network,
              options: QueryOptions(document: gql('query { test }')),
            ),
          );
          when(() => mockAuthRepository.saveCredentials(
                serverUrl: any(named: 'serverUrl'),
                apiKey: any(named: 'apiKey'),
              )).thenAnswer((_) async => {});
          return AuthCubit(mockAuthRepository, mockClientManager);
        },
        act: (cubit) => cubit.login('http://test.server', 'test-api-key'),
        expect: () => [
          const AuthLoading(),
          const Authenticated(serverUrl: 'http://test.server'),
        ],
        verify: (_) {
          verify(() => mockClientManager.configure(
                serverUrl: 'http://test.server',
                apiKey: 'test-api-key',
              )).called(1);
          verify(() => mockAuthRepository.saveCredentials(
                serverUrl: 'http://test.server',
                apiKey: 'test-api-key',
              )).called(1);
          verify(() => mockGraphQLClient.query(any())).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when connection test fails',
        build: () {
          when(() => mockClientManager.configure(
                serverUrl: any(named: 'serverUrl'),
                apiKey: any(named: 'apiKey'),
              )).thenReturn(null);
          when(() => mockClientManager.reset()).thenReturn(null);
          when(() => mockGraphQLClient.query(any())).thenAnswer(
            (_) async => QueryResult(
              data: null,
              source: QueryResultSource.network,
              options: QueryOptions(document: gql('query { test }')),
              exception: OperationException(),
            ),
          );
          return AuthCubit(mockAuthRepository, mockClientManager);
        },
        act: (cubit) => cubit.login('http://test.server', 'test-api-key'),
        expect: () => [
          const AuthLoading(),
          const AuthError(
              'Could not connect to server. Check your address and API key.'),
        ],
        verify: (_) {
          verify(() => mockClientManager.reset()).called(1);
          verifyNever(() => mockAuthRepository.saveCredentials(
                serverUrl: any(named: 'serverUrl'),
                apiKey: any(named: 'apiKey'),
              ));
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when connection test throws',
        build: () {
          when(() => mockClientManager.configure(
                serverUrl: any(named: 'serverUrl'),
                apiKey: any(named: 'apiKey'),
              )).thenReturn(null);
          when(() => mockClientManager.reset()).thenReturn(null);
          when(() => mockGraphQLClient.query(any()))
              .thenThrow(Exception('Network error'));
          return AuthCubit(mockAuthRepository, mockClientManager);
        },
        act: (cubit) => cubit.login('http://test.server', 'test-api-key'),
        expect: () => [
          const AuthLoading(),
          const AuthError('Unexpected error during login.'),
        ],
        verify: (_) {
          verify(() => mockClientManager.reset()).called(1);
        },
      );
    });

    group('logout', () {
      blocTest<AuthCubit, AuthState>(
        'emits [Unauthenticated] and clears credentials',
        build: () {
          when(() => mockAuthRepository.clearCredentials())
              .thenAnswer((_) async => {});
          when(() => mockClientManager.reset()).thenReturn(null);
          return AuthCubit(mockAuthRepository, mockClientManager);
        },
        act: (cubit) => cubit.logout(),
        expect: () => [
          const Unauthenticated(),
        ],
        verify: (_) {
          verify(() => mockAuthRepository.clearCredentials()).called(1);
          verify(() => mockClientManager.reset()).called(1);
        },
      );
    });
  });
}
