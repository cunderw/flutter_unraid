import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/blocs/auth/auth_cubit.dart';
import 'package:flutter_unraid/blocs/docker/docker_cubit.dart';
import 'package:flutter_unraid/blocs/shares/shares_cubit.dart';
import 'package:flutter_unraid/blocs/system/system_cubit.dart';
import 'package:flutter_unraid/blocs/vms/vm_cubit.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/data/repositories/docker_repository.dart';
import 'package:flutter_unraid/data/repositories/share_repository.dart';
import 'package:flutter_unraid/data/repositories/system_repository.dart';
import 'package:flutter_unraid/data/repositories/vm_repository.dart';
import 'package:flutter_unraid/di/injection.dart';
import 'package:flutter_unraid/ui/screens/tabs/main_tab.dart';
import 'package:flutter_unraid/ui/screens/tabs/docker_tab.dart';
import 'package:flutter_unraid/ui/screens/tabs/vms_tab.dart';
import 'package:flutter_unraid/ui/screens/tabs/shares_tab.dart';

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
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Unraid Manager'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () => _refreshCurrentTab(context),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  context.read<AuthCubit>().logout();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text('Disconnect'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: IndexedStack(index: _currentIndex, children: _tabs),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          backgroundColor: AppColors.surface,
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
