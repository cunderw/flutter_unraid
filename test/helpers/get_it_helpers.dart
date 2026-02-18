import 'package:get_it/get_it.dart';

import 'package:flutter_unraid/data/repositories/docker_repository.dart';
import 'package:flutter_unraid/data/repositories/notification_repository.dart';
import 'package:flutter_unraid/data/repositories/share_repository.dart';
import 'package:flutter_unraid/data/repositories/system_repository.dart';
import 'package:flutter_unraid/data/repositories/vm_repository.dart';

/// Resets [GetIt] to a clean state. Call in [setUp] or [tearDown].
/// Must be awaited — [GetIt.reset] is async in GetIt 8.x.
Future<void> resetGetIt() async {
  await GetIt.instance.reset();
}

/// Registers mock repositories in GetIt for testing.
void registerMockRepositories({
  SystemRepository? systemRepo,
  DockerRepository? dockerRepo,
  VmRepository? vmRepo,
  ShareRepository? shareRepo,
  NotificationRepository? notificationRepo,
}) {
  final getIt = GetIt.instance;

  if (systemRepo != null) {
    getIt.registerLazySingleton<SystemRepository>(() => systemRepo);
  }

  if (dockerRepo != null) {
    getIt.registerLazySingleton<DockerRepository>(() => dockerRepo);
  }

  if (vmRepo != null) {
    getIt.registerLazySingleton<VmRepository>(() => vmRepo);
  }

  if (shareRepo != null) {
    getIt.registerLazySingleton<ShareRepository>(() => shareRepo);
  }

  if (notificationRepo != null) {
    getIt.registerLazySingleton<NotificationRepository>(() => notificationRepo);
  }
}
