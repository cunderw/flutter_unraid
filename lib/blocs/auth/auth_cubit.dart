import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';

import 'package:flutter_unraid/blocs/auth/auth_state.dart';
import 'package:flutter_unraid/data/repositories/auth_repository.dart';
import 'package:flutter_unraid/graphql/client.dart';
import 'package:flutter_unraid/graphql/queries.dart';
import 'package:flutter_unraid/utils/app_exception.dart';
import 'package:flutter_unraid/utils/log.dart';

class AuthCubit extends Cubit<AuthState> {
  static const _tag = 'AuthCubit';
  final AuthRepository _authRepository;
  final GraphQLClientManager _clientManager;

  AuthCubit(this._authRepository, this._clientManager)
    : super(const AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    try {
      final credentials = await _authRepository.getCredentials();
      if (credentials != null) {
        _clientManager.configure(
          serverUrl: credentials.serverUrl,
          apiKey: credentials.apiKey,
        );
        final connected = await _testConnection();
        if (connected) {
          Log.i('Auto-authenticated to ${credentials.serverUrl}', tag: _tag);
          emit(Authenticated(serverUrl: credentials.serverUrl));
        } else {
          Log.w('Stored credentials failed connection test', tag: _tag);
          _clientManager.reset();
          emit(const Unauthenticated());
        }
      } else {
        Log.d('No stored credentials found', tag: _tag);
        emit(const Unauthenticated());
      }
    } catch (e, st) {
      Log.e('Auth status check failed', tag: _tag, error: e, stackTrace: st);
      emit(const Unauthenticated());
    }
  }

  Future<void> login(String serverUrl, String apiKey) async {
    emit(const AuthLoading());
    try {
      _clientManager.configure(serverUrl: serverUrl, apiKey: apiKey);
      final connected = await _testConnection();
      if (connected) {
        await _authRepository.saveCredentials(
          serverUrl: serverUrl,
          apiKey: apiKey,
        );
        Log.i('Login successful to $serverUrl', tag: _tag);
        emit(Authenticated(serverUrl: serverUrl));
      } else {
        Log.w(
          'Login failed — connection test unsuccessful for $serverUrl',
          tag: _tag,
        );
        _clientManager.reset();
        emit(
          const AuthError(
            'Could not connect to server. Check your address and API key.',
          ),
        );
      }
    } catch (e, st) {
      Log.e('Login failed for $serverUrl', tag: _tag, error: e, stackTrace: st);
      _clientManager.reset();
      final appError = AppException.from(e, operation: 'login', stackTrace: st);
      emit(AuthError(appError.message));
    }
  }

  Future<void> logout() async {
    Log.i('Logging out', tag: _tag);
    await _authRepository.clearCredentials();
    _clientManager.reset();
    emit(const Unauthenticated());
  }

  Future<bool> _testConnection() async {
    Log.d('Testing connection...', tag: _tag);
    try {
      final result = await _clientManager.client.query(
        QueryOptions(
          document: gql(Queries.testConnection),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );
      final ok = !result.hasException && result.data != null;
      Log.d('Connection test: ${ok ? 'passed' : 'failed'}', tag: _tag);
      return ok;
    } catch (e, st) {
      Log.e('Connection test threw', tag: _tag, error: e, stackTrace: st);
      return false;
    }
  }
}
