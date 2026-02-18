# New Screen

Scaffold a new screen widget that consumes a cubit via BlocBuilder with exhaustive state handling.

## Inputs

- **Screen name** (e.g., `NotificationsTab`, `ShareDetailScreen`)
- **Cubit type** it consumes (e.g., `NotificationsCubit`)
- **State type** (e.g., `NotificationsState`)
- **Screen type** — `tab` (lives inside HomeScreen's BottomNavigationBar) or `detail` (pushed via Navigator)
- **Data to display** (e.g., list of items, single entity detail)

## Output File

`lib/ui/screens/<feature>/<screen_name>.dart`

## Screen Pattern

Follow `lib/ui/screens/home/tabs/docker_tab.dart` for the canonical example.

### Tab Screen (list view)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/<cubit_import>.dart';
import 'package:flutter_unraid/<state_import>.dart';
import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/ui/widgets/feedback/empty_state.dart';
import 'package:flutter_unraid/ui/widgets/feedback/error_display.dart';
import 'package:flutter_unraid/ui/widgets/feedback/error_snackbar.dart';
import 'package:flutter_unraid/ui/widgets/feedback/loading_indicator.dart';
import 'package:flutter_unraid/ui/widgets/layout/section_header.dart';

class <Screen> extends StatelessWidget {
  const <Screen>({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<<Cubit>, <State>>(
      listenWhen: (_, current) => current is <Feature>ActionError,
      listener: (context, state) {
        if (state is <Feature>ActionError) {
          showErrorSnackbar(context, message: state.message);
        }
      },
      child: BlocBuilder<<Cubit>, <State>>(
        buildWhen: (_, current) => current is! <Feature>ActionError,
        builder: (context, state) {
          // Extract data from loaded or action-error states
          final items = switch (state) {
            <Feature>Loaded(:final items) => items,
            <Feature>ActionError(:final items) => items,
            _ => null,
          };

          if (state is <Feature>Initial || state is <Feature>Loading) {
            return const LoadingIndicator(message: 'Loading...');
          }

          if (state is <Feature>Error) {
            return ErrorDisplay(
              message: state.message,
              onRetry: () => context.read<<Cubit>>().refresh(),
            );
          }

          if (items == null || items.isEmpty) {
            return const EmptyState(
              message: 'No items found.',
              icon: Icons.inbox_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<<Cubit>>().refresh(),
            color: AppColors.unraidOrange,
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              children: [
                SectionHeader(title: '<Title>'),
                ...items.map((item) => _ItemTile(item: item)),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

### Detail Screen (pushed via Navigator)

```dart
class <Detail>Screen extends StatelessWidget {
  final String itemId;
  const <Detail>Screen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('<Title>')),
      body: BlocBuilder<<Cubit>, <State>>(
        builder: (context, state) => switch (state) {
          <Feature>Initial() || <Feature>Loading() =>
            const LoadingIndicator(),
          <Feature>Error(:final message) =>
            ErrorDisplay(message: message, onRetry: () => context.read<<Cubit>>().load()),
          <Feature>Loaded() => _buildContent(context, state),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}
```

## Rules

- `const` constructor with `super.key`
- `StatelessWidget` unless local mutable state is needed
- Use `BlocListener` for ActionError → snackbar, `BlocBuilder` for rendering
- `buildWhen` filter to prevent ActionError from triggering a rebuild
- Exhaustive `switch` expressions on sealed state for routing
- `RefreshIndicator` with `AppColors.unraidOrange` for pull-to-refresh
- Use reusable widgets: `LoadingIndicator`, `ErrorDisplay`, `EmptyState`, `SectionHeader`, `ActionCard`, `StatusBadge`
- Spacing via `AppSpacing` constants and gap widgets
- Private `_ItemTile` widget for list items, in the same file
- Navigation: `Navigator.of(context).push(MaterialPageRoute(...))` with `BlocProvider.value` to pass cubit to detail screens
