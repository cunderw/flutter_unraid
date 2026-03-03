import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql/client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_unraid/blocs/auth/auth_state.dart';
import 'package:flutter_unraid/blocs/docker/docker_state.dart';
import 'package:flutter_unraid/blocs/notifications/notification_state.dart';
import 'package:flutter_unraid/blocs/settings/settings_state.dart';
import 'package:flutter_unraid/blocs/shares/shares_state.dart';
import 'package:flutter_unraid/blocs/system/system_state.dart';
import 'package:flutter_unraid/blocs/vms/vm_state.dart';
import 'package:flutter_unraid/blocs/auth/auth_cubit.dart';
import 'package:flutter_unraid/blocs/docker/docker_cubit.dart';
import 'package:flutter_unraid/blocs/notifications/notification_cubit.dart';
import 'package:flutter_unraid/blocs/settings/settings_cubit.dart';
import 'package:flutter_unraid/blocs/shares/shares_cubit.dart';
import 'package:flutter_unraid/blocs/system/system_cubit.dart';
import 'package:flutter_unraid/blocs/vms/vm_cubit.dart';
import 'package:flutter_unraid/data/repositories/auth_repository.dart';
import 'package:flutter_unraid/data/repositories/docker_repository.dart';
import 'package:flutter_unraid/data/repositories/notification_repository.dart';
import 'package:flutter_unraid/data/repositories/settings_repository.dart';
import 'package:flutter_unraid/data/repositories/share_repository.dart';
import 'package:flutter_unraid/data/repositories/system_repository.dart';
import 'package:flutter_unraid/data/repositories/vm_repository.dart';
import 'package:flutter_unraid/graphql/client.dart';
import 'package:flutter_unraid/ui/screens/container_detail/cubit/container_logs_cubit.dart';
import 'package:flutter_unraid/ui/screens/container_detail/cubit/container_logs_state.dart';
import 'package:flutter_unraid/ui/screens/home/tabs/main_tab/cubit/system_logs_cubit.dart';
import 'package:flutter_unraid/ui/screens/home/tabs/main_tab/cubit/system_logs_state.dart';

// Core services
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockGraphQLClientManager extends Mock implements GraphQLClientManager {}

class MockGraphQLClient extends Mock implements GraphQLClient {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

// Repositories
class MockAuthRepository extends Mock implements AuthRepository {}

class MockSystemRepository extends Mock implements SystemRepository {}

class MockDockerRepository extends Mock implements DockerRepository {}

class MockVmRepository extends Mock implements VmRepository {}

class MockShareRepository extends Mock implements ShareRepository {}

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

// Cubits (for widget tests)
class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockSystemCubit extends MockCubit<SystemState> implements SystemCubit {}

class MockDockerCubit extends MockCubit<DockerState> implements DockerCubit {}

class MockVmCubit extends MockCubit<VmState> implements VmCubit {}

class MockSharesCubit extends MockCubit<SharesState> implements SharesCubit {}

class MockNotificationCubit extends MockCubit<NotificationState>
    implements NotificationCubit {}

class MockSettingsCubit extends MockCubit<SettingsState>
    implements SettingsCubit {}

class MockContainerLogsCubit extends MockCubit<ContainerLogsState>
    implements ContainerLogsCubit {}

class MockSystemLogsCubit extends MockCubit<SystemLogsState>
    implements SystemLogsCubit {}

/// Helper class to create a BlocProvider with a mocked cubit for testing.
class MockBlocProvider<C extends StateStreamableSource<S>, S>
    extends BlocProvider<C> {
  MockBlocProvider({required C cubit, required S state, super.key})
    : super.value(
        value: cubit,
        child: Builder(
          builder: (context) {
            when(() => cubit.state).thenReturn(state);
            return const SizedBox.shrink();
          },
        ),
      );
}
