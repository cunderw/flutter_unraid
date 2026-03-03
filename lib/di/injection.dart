import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_unraid/blocs/settings/settings_cubit.dart';
import 'package:flutter_unraid/data/repositories/auth_repository.dart';
import 'package:flutter_unraid/data/repositories/docker_repository.dart';
import 'package:flutter_unraid/data/repositories/notification_repository.dart';
import 'package:flutter_unraid/data/repositories/settings_repository.dart';
import 'package:flutter_unraid/data/repositories/share_repository.dart';
import 'package:flutter_unraid/data/repositories/system_repository.dart';
import 'package:flutter_unraid/data/repositories/vm_repository.dart';
import 'package:flutter_unraid/graphql/client.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // ── Core services ──────────────────────────────────────
  getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
  getIt.registerSingleton<GraphQLClientManager>(GraphQLClientManager());
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // ── Repositories ───────────────────────────────────────
  getIt.registerSingleton<AuthRepository>(
    AuthRepository(getIt<FlutterSecureStorage>()),
  );
  getIt.registerLazySingleton<SystemRepository>(
    () => SystemRepository(getIt<GraphQLClientManager>()),
  );
  getIt.registerLazySingleton<DockerRepository>(
    () => DockerRepository(getIt<GraphQLClientManager>()),
  );
  getIt.registerLazySingleton<VmRepository>(
    () => VmRepository(getIt<GraphQLClientManager>()),
  );
  getIt.registerLazySingleton<ShareRepository>(
    () => ShareRepository(getIt<GraphQLClientManager>()),
  );
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepository(getIt<GraphQLClientManager>()),
  );
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepository(getIt<SharedPreferences>()),
  );

  // ── Cubits ─────────────────────────────────────────────
  getIt.registerLazySingleton<SettingsCubit>(
    () => SettingsCubit(getIt<SettingsRepository>())..loadSettings(),
  );
}
