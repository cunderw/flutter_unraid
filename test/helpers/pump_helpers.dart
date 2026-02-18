import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_unraid/blocs/auth/auth_cubit.dart';
import 'package:flutter_unraid/blocs/auth/auth_state.dart';
import 'package:flutter_unraid/blocs/docker/docker_cubit.dart';
import 'package:flutter_unraid/blocs/docker/docker_state.dart';
import 'package:flutter_unraid/blocs/shares/shares_cubit.dart';
import 'package:flutter_unraid/blocs/shares/shares_state.dart';
import 'package:flutter_unraid/blocs/system/system_cubit.dart';
import 'package:flutter_unraid/blocs/system/system_state.dart';
import 'package:flutter_unraid/blocs/vms/vm_cubit.dart';
import 'package:flutter_unraid/blocs/vms/vm_state.dart';
import 'package:flutter_unraid/config/theme.dart';

extension PumpHelpers on WidgetTester {
  /// Pumps [widget] wrapped in a [MaterialApp] with the Unraid dark theme.
  Future<void> pumpApp(Widget widget) async {
    await pumpWidget(
      MaterialApp(
        theme: unraidDarkTheme,
        home: Scaffold(body: widget),
      ),
    );
  }

  /// Pumps [widget] wrapped in a [MaterialApp] with [BlocProvider]s.
  Future<void> pumpAppWithBlocs(
    Widget widget, {
    List<BlocProvider>? providers,
    AuthCubit? authCubit,
    AuthState? authState,
    DockerCubit? dockerCubit,
    DockerState? dockerState,
    SystemCubit? systemCubit,
    SystemState? systemState,
    VmCubit? vmCubit,
    VmState? vmState,
    SharesCubit? sharesCubit,
    SharesState? sharesState,
  }) async {
    final blocProviders = <BlocProvider>[];

    // Add provided cubits with their states
    if (authCubit != null) {
      if (authState != null) {
        when(() => authCubit.state).thenReturn(authState);
      }
      blocProviders.add(BlocProvider<AuthCubit>.value(value: authCubit));
    }

    if (dockerCubit != null) {
      if (dockerState != null) {
        when(() => dockerCubit.state).thenReturn(dockerState);
      }
      blocProviders.add(BlocProvider<DockerCubit>.value(value: dockerCubit));
    }

    if (systemCubit != null) {
      if (systemState != null) {
        when(() => systemCubit.state).thenReturn(systemState);
      }
      blocProviders.add(BlocProvider<SystemCubit>.value(value: systemCubit));
    }

    if (vmCubit != null) {
      if (vmState != null) {
        when(() => vmCubit.state).thenReturn(vmState);
      }
      blocProviders.add(BlocProvider<VmCubit>.value(value: vmCubit));
    }

    if (sharesCubit != null) {
      if (sharesState != null) {
        when(() => sharesCubit.state).thenReturn(sharesState);
      }
      blocProviders.add(BlocProvider<SharesCubit>.value(value: sharesCubit));
    }

    // Add any additional providers
    if (providers != null) {
      blocProviders.addAll(providers);
    }

    await pumpWidget(
      MaterialApp(
        theme: unraidDarkTheme,
        home: MultiBlocProvider(
          providers: blocProviders,
          child: Scaffold(body: widget),
        ),
      ),
    );
  }
}
