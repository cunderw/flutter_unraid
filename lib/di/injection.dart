import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import 'package:flutter_unraid/data/repositories/auth_repository.dart';
import 'package:flutter_unraid/data/repositories/docker_repository.dart';
import 'package:flutter_unraid/data/repositories/notification_repository.dart';
import 'package:flutter_unraid/data/repositories/share_repository.dart';
import 'package:flutter_unraid/data/repositories/system_repository.dart';
import 'package:flutter_unraid/data/repositories/vm_repository.dart';
import 'package:flutter_unraid/graphql/client.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // ── Core services ──────────────────────────────────────
  getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
  getIt.registerSingleton<GraphQLClientManager>(GraphQLClientManager());

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
}
