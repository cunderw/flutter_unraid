import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unraid/data/repositories/auth_repository.dart';
import 'package:flutter_unraid/utils/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late AuthRepository repository;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    repository = AuthRepository(mockStorage);
  });

  group('AuthRepository', () {
    group('saveCredentials', () {
      test('saves serverUrl and apiKey to secure storage', () async {
        when(() => mockStorage.write(
              key: any(named: 'key'),
              value: any(named: 'value'),
            )).thenAnswer((_) async => {});

        await repository.saveCredentials(
          serverUrl: 'http://test.server',
          apiKey: 'test-api-key',
        );

        verify(() => mockStorage.write(
              key: AppConstants.keyServerUrl,
              value: 'http://test.server',
            )).called(1);
        verify(() => mockStorage.write(
              key: AppConstants.keyApiKey,
              value: 'test-api-key',
            )).called(1);
      });
    });

    group('getCredentials', () {
      test('returns credentials when both serverUrl and apiKey exist', () async {
        when(() => mockStorage.read(key: AppConstants.keyServerUrl))
            .thenAnswer((_) async => 'http://test.server');
        when(() => mockStorage.read(key: AppConstants.keyApiKey))
            .thenAnswer((_) async => 'test-api-key');

        final result = await repository.getCredentials();

        expect(result, isNotNull);
        expect(result!.serverUrl, 'http://test.server');
        expect(result.apiKey, 'test-api-key');
      });

      test('returns null when serverUrl is missing', () async {
        when(() => mockStorage.read(key: AppConstants.keyServerUrl))
            .thenAnswer((_) async => null);
        when(() => mockStorage.read(key: AppConstants.keyApiKey))
            .thenAnswer((_) async => 'test-api-key');

        final result = await repository.getCredentials();

        expect(result, isNull);
      });

      test('returns null when apiKey is missing', () async {
        when(() => mockStorage.read(key: AppConstants.keyServerUrl))
            .thenAnswer((_) async => 'http://test.server');
        when(() => mockStorage.read(key: AppConstants.keyApiKey))
            .thenAnswer((_) async => null);

        final result = await repository.getCredentials();

        expect(result, isNull);
      });

      test('returns null when both credentials are missing', () async {
        when(() => mockStorage.read(key: any(named: 'key')))
            .thenAnswer((_) async => null);

        final result = await repository.getCredentials();

        expect(result, isNull);
      });
    });

    group('clearCredentials', () {
      test('deletes both serverUrl and apiKey from secure storage', () async {
        when(() => mockStorage.delete(key: any(named: 'key')))
            .thenAnswer((_) async => {});

        await repository.clearCredentials();

        verify(() => mockStorage.delete(key: AppConstants.keyServerUrl))
            .called(1);
        verify(() => mockStorage.delete(key: AppConstants.keyApiKey)).called(1);
      });
    });
  });
}
