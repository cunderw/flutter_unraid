import 'package:get_it/get_it.dart';

import 'package:flutter_unraid/data/repositories/docker_repository.dart';
import 'package:flutter_unraid/data/repositories/share_repository.dart';
import 'package:flutter_unraid/data/repositories/system_repository.dart';
import 'package:flutter_unraid/data/repositories/vm_repository.dart';

/// Resets [GetIt] to a clean state. Call in [setUp] or [tearDown].
void resetGetIt() {
  GetIt.instance.reset();
}

/// Registers mock repositories in GetIt for testing.
void registerMockRepositories({
  SystemRepository? systemRepo,
  DockerRepository? dockerRepo,
  VmRepository? vmRepo,
  ShareRepository? shareRepo,
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
}
