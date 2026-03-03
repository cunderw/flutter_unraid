import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/blocs/auth/auth_cubit.dart';
import 'package:flutter_unraid/blocs/settings/settings_cubit.dart';
import 'package:flutter_unraid/blocs/settings/settings_state.dart';
import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/config/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<AuthCubit>()),
            BlocProvider.value(value: context.read<SettingsCubit>()),
          ],
          child: const SettingsScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) => switch (state) {
          SettingsLoading() || SettingsInitial() => const Center(
            child: CircularProgressIndicator(color: AppColors.unraidOrange),
          ),
          SettingsError(:final message) => Center(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.stopped),
            ),
          ),
          SettingsLoaded(:final settings) => ListView(
            children: [
              AppSpacing.verticalSm,
              _SectionHeader(title: 'General'),
              SwitchListTile(
                title: const Text('Open links externally'),
                subtitle: const Text(
                  'Open links in your default browser instead of the in-app viewer',
                ),
                value: settings.openLinksExternally,
                activeTrackColor: AppColors.unraidOrange,
                onChanged: (value) =>
                    context.read<SettingsCubit>().setOpenLinksExternally(value),
              ),
              const Divider(),
              _SectionHeader(title: 'Account'),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.stopped),
                title: const Text(
                  'Disconnect',
                  style: TextStyle(color: AppColors.stopped),
                ),
                subtitle: const Text('Log out from the Unraid server'),
                onTap: () => _showLogoutConfirmation(context),
              ),
            ],
          ),
        },
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Disconnect'),
        content: const Text(
          'Are you sure you want to disconnect from the server?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.stopped),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        context.read<AuthCubit>().logout();
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.unraidOrange,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
