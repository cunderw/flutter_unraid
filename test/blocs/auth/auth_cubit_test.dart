import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_unraid/blocs/auth/auth_cubit.dart';
import 'package:flutter_unraid/blocs/auth/auth_state.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockGraphQLClientManager mockClientManager;
  late MockGraphQLClient mockGraphQLClient;

  setUpAll(() {
    registerFallbackValue(QueryOptions(document: gql('query {}')));
  });

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockClientManager = MockGraphQLClientManager();
    mockGraphQLClient = MockGraphQLClient();

    when(() => mockClientManager.client).thenReturn(mockGraphQLClient);
  });

  AuthCubit buildCubit() => AuthCubit(mockAuthRepo, mockClientManager);

  group('AuthCubit', () {
    test('initial state is AuthInitial', () {
      expect(buildCubit().state, const AuthInitial());
    });

    group('checkAuthStatus', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, Unauthenticated] when no stored credentials',
        build: () {
          when(
            () => mockAuthRepo.getCredentials(),
          ).thenAnswer((_) async => null);
          return buildCubit();
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [const AuthLoading(), const Unauthenticated()],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, Authenticated] when stored credentials pass connection test',
        build: () {
          when(() => mockAuthRepo.getCredentials()).thenAnswer(
            (_) async =>
                (serverUrl: 'http://192.168.1.100', apiKey: 'test-key'),
          );
          when(
            () => mockClientManager.configure(
              serverUrl: any(named: 'serverUrl'),
              apiKey: any(named: 'apiKey'),
            ),
          ).thenReturn(null);
          when(() => mockGraphQLClient.query(any())).thenAnswer(
            (_) async => QueryResult(
              data: {
                'info': {
                  'os': {'platform': 'linux'},
                },
              },
              source: QueryResultSource.network,
              options: QueryOptions(document: gql('query {}')),
            ),
          );
          return buildCubit();
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [
          const AuthLoading(),
          const Authenticated(serverUrl: 'http://192.168.1.100'),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, Unauthenticated] when stored credentials fail connection test',
        build: () {
          when(() => mockAuthRepo.getCredentials()).thenAnswer(
            (_) async => (serverUrl: 'http://192.168.1.100', apiKey: 'bad-key'),
          );
          when(
            () => mockClientManager.configure(
              serverUrl: any(named: 'serverUrl'),
              apiKey: any(named: 'apiKey'),
            ),
          ).thenReturn(null);
          when(() => mockClientManager.reset()).thenReturn(null);
          when(() => mockGraphQLClient.query(any())).thenAnswer(
            (_) async => QueryResult(
              exception: OperationException(),
              source: QueryResultSource.network,
              options: QueryOptions(document: gql('query {}')),
            ),
          );
          return buildCubit();
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [const AuthLoading(), const Unauthenticated()],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, Unauthenticated] when getCredentials throws',
        build: () {
          when(
            () => mockAuthRepo.getCredentials(),
          ).thenThrow(Exception('storage error'));
          return buildCubit();
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [const AuthLoading(), const Unauthenticated()],
      );
    });

    group('login', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, Authenticated] on successful login',
        build: () {
          when(
            () => mockClientManager.configure(
              serverUrl: any(named: 'serverUrl'),
              apiKey: any(named: 'apiKey'),
            ),
          ).thenReturn(null);
          when(() => mockGraphQLClient.query(any())).thenAnswer(
            (_) async => QueryResult(
              data: {
                'info': {
                  'os': {'platform': 'linux'},
                },
              },
              source: QueryResultSource.network,
              options: QueryOptions(document: gql('query {}')),
            ),
          );
          when(
            () => mockAuthRepo.saveCredentials(
              serverUrl: any(named: 'serverUrl'),
              apiKey: any(named: 'apiKey'),
            ),
          ).thenAnswer((_) async {});
          return buildCubit();
        },
        act: (cubit) => cubit.login('http://192.168.1.100', 'valid-key'),
        expect: () => [
          const AuthLoading(),
          const Authenticated(serverUrl: 'http://192.168.1.100'),
        ],
        verify: (_) {
          verify(
            () => mockAuthRepo.saveCredentials(
              serverUrl: 'http://192.168.1.100',
              apiKey: 'valid-key',
            ),
          ).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when connection test fails',
        build: () {
          when(
            () => mockClientManager.configure(
              serverUrl: any(named: 'serverUrl'),
              apiKey: any(named: 'apiKey'),
            ),
          ).thenReturn(null);
          when(() => mockClientManager.reset()).thenReturn(null);
          when(() => mockGraphQLClient.query(any())).thenAnswer(
            (_) async => QueryResult(
              exception: OperationException(),
              source: QueryResultSource.network,
              options: QueryOptions(document: gql('query {}')),
            ),
          );
          return buildCubit();
        },
        act: (cubit) => cubit.login('http://bad-host', 'bad-key'),
        expect: () => [
          const AuthLoading(),
          const AuthError(
            'Could not connect to server. Check your address and API key.',
          ),
        ],
        verify: (_) {
          verify(() => mockClientManager.reset()).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when login throws exception',
        build: () {
          when(
            () => mockClientManager.configure(
              serverUrl: any(named: 'serverUrl'),
              apiKey: any(named: 'apiKey'),
            ),
          ).thenReturn(null);
          when(() => mockClientManager.reset()).thenReturn(null);
          when(
            () => mockGraphQLClient.query(any()),
          ).thenThrow(Exception('network failure'));
          return buildCubit();
        },
        act: (cubit) => cubit.login('http://192.168.1.100', 'key'),
        expect: () => [const AuthLoading(), isA<AuthError>()],
        verify: (_) {
          verify(() => mockClientManager.reset()).called(1);
        },
      );
    });

    group('logout', () {
      blocTest<AuthCubit, AuthState>(
        'emits [Unauthenticated] and clears credentials',
        build: () {
          when(() => mockAuthRepo.clearCredentials()).thenAnswer((_) async {});
          when(() => mockClientManager.reset()).thenReturn(null);
          return buildCubit();
        },
        act: (cubit) => cubit.logout(),
        expect: () => [const Unauthenticated()],
        verify: (_) {
          verify(() => mockAuthRepo.clearCredentials()).called(1);
          verify(() => mockClientManager.reset()).called(1);
        },
      );
    });
  });
}
