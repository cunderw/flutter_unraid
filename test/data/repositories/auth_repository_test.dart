import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_unraid/data/repositories/auth_repository.dart';
import 'package:flutter_unraid/utils/constants.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockFlutterSecureStorage mockStorage;
  late AuthRepository repo;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    repo = AuthRepository(mockStorage);
  });

  group('AuthRepository', () {
    group('saveCredentials', () {
      test('writes server URL and API key to secure storage', () async {
        when(
          () => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});

        await repo.saveCredentials(
          serverUrl: 'http://192.168.1.100',
          apiKey: 'my-key',
        );

        verify(
          () => mockStorage.write(
            key: AppConstants.keyServerUrl,
            value: 'http://192.168.1.100',
          ),
        ).called(1);
        verify(
          () => mockStorage.write(key: AppConstants.keyApiKey, value: 'my-key'),
        ).called(1);
      });
    });

    group('getCredentials', () {
      test('returns credentials when both values exist', () async {
        when(
          () => mockStorage.read(key: AppConstants.keyServerUrl),
        ).thenAnswer((_) async => 'http://192.168.1.100');
        when(
          () => mockStorage.read(key: AppConstants.keyApiKey),
        ).thenAnswer((_) async => 'my-key');

        final result = await repo.getCredentials();

        expect(result, isNotNull);
        expect(result!.serverUrl, 'http://192.168.1.100');
        expect(result.apiKey, 'my-key');
      });

      test('returns null when server URL is missing', () async {
        when(
          () => mockStorage.read(key: AppConstants.keyServerUrl),
        ).thenAnswer((_) async => null);
        when(
          () => mockStorage.read(key: AppConstants.keyApiKey),
        ).thenAnswer((_) async => 'my-key');

        final result = await repo.getCredentials();

        expect(result, isNull);
      });

      test('returns null when API key is missing', () async {
        when(
          () => mockStorage.read(key: AppConstants.keyServerUrl),
        ).thenAnswer((_) async => 'http://192.168.1.100');
        when(
          () => mockStorage.read(key: AppConstants.keyApiKey),
        ).thenAnswer((_) async => null);

        final result = await repo.getCredentials();

        expect(result, isNull);
      });

      test('returns null when both values are missing', () async {
        when(
          () => mockStorage.read(key: any(named: 'key')),
        ).thenAnswer((_) async => null);

        final result = await repo.getCredentials();

        expect(result, isNull);
      });
    });

    group('clearCredentials', () {
      test('deletes both keys from secure storage', () async {
        when(
          () => mockStorage.delete(key: any(named: 'key')),
        ).thenAnswer((_) async {});

        await repo.clearCredentials();

        verify(
          () => mockStorage.delete(key: AppConstants.keyServerUrl),
        ).called(1);
        verify(() => mockStorage.delete(key: AppConstants.keyApiKey)).called(1);
      });
    });
  });
}
