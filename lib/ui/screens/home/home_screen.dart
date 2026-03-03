import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/blocs/docker/docker_cubit.dart';
import 'package:flutter_unraid/blocs/notifications/notification_cubit.dart';
import 'package:flutter_unraid/blocs/notifications/notification_state.dart';
import 'package:flutter_unraid/blocs/shares/shares_cubit.dart';
import 'package:flutter_unraid/blocs/system/system_cubit.dart';
import 'package:flutter_unraid/blocs/vms/vm_cubit.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/data/repositories/docker_repository.dart';
import 'package:flutter_unraid/data/repositories/notification_repository.dart';
import 'package:flutter_unraid/data/repositories/share_repository.dart';
import 'package:flutter_unraid/data/repositories/system_repository.dart';
import 'package:flutter_unraid/data/repositories/vm_repository.dart';
import 'package:flutter_unraid/di/injection.dart';
import 'package:flutter_unraid/ui/screens/home/tabs/main_tab.dart';
import 'package:flutter_unraid/ui/screens/home/tabs/docker_tab.dart';
import 'package:flutter_unraid/ui/screens/home/tabs/vms_tab.dart';
import 'package:flutter_unraid/ui/screens/home/tabs/shares_tab.dart';
import 'package:flutter_unraid/ui/screens/notifications/notifications_screen.dart';
import 'package:flutter_unraid/ui/screens/settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static final _tabs = [
    const MainTab(),
    const DockerTab(),
    const VmsTab(),
    const SharesTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SystemCubit(getIt<SystemRepository>())..load(),
        ),
        BlocProvider(
          create: (_) => DockerCubit(getIt<DockerRepository>())..load(),
        ),
        BlocProvider(create: (_) => VmCubit(getIt<VmRepository>())..load()),
        BlocProvider(
          create: (_) => SharesCubit(getIt<ShareRepository>())..load(),
        ),
        BlocProvider(
          create: (_) =>
              NotificationCubit(getIt<NotificationRepository>())..load(),
        ),
      ],
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Unraid Manager'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: () => _refreshCurrentTab(context),
              ),
              _NotificationBellButton(),
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Settings',
                onPressed: () => SettingsScreen.open(context),
              ),
            ],
          ),
          body: IndexedStack(index: _currentIndex, children: _tabs),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) =>
                setState(() => _currentIndex = index),
            backgroundColor: Theme.of(context).colorScheme.surface,
            indicatorColor: AppColors.unraidOrange.withValues(alpha: 0.2),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Main',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: 'Docker',
              ),
              NavigationDestination(
                icon: Icon(Icons.computer_outlined),
                selectedIcon: Icon(Icons.computer),
                label: 'VMs',
              ),
              NavigationDestination(
                icon: Icon(Icons.folder_shared_outlined),
                selectedIcon: Icon(Icons.folder_shared),
                label: 'Shares',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _refreshCurrentTab(BuildContext context) {
    switch (_currentIndex) {
      case 0:
        context.read<SystemCubit>().refresh();
      case 1:
        context.read<DockerCubit>().refresh();
      case 2:
        context.read<VmCubit>().refresh();
      case 3:
        context.read<SharesCubit>().refresh();
    }
  }
}

class _NotificationBellButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final count = switch (state) {
          NotificationLoaded(:final totalCount) => totalCount,
          NotificationActionError(:final totalCount) => totalCount,
          _ => 0,
        };

        return IconButton(
          icon: Badge(
            isLabelVisible: count > 0,
            label: Text(
              count > 99 ? '99+' : count.toString(),
              style: const TextStyle(fontSize: 10),
            ),
            child: const Icon(Icons.notifications_outlined),
          ),
          tooltip: 'Notifications',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider.value(
                  value: context.read<NotificationCubit>(),
                  child: const NotificationsScreen(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
