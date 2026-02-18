# New Screen

Scaffold a new screen widget that consumes a cubit via BlocBuilder with exhaustive state handling.

## Usage

`/project:new-screen <screen name and details>`

Provide: screen name, cubit/state types, screen type (tab or detail), and data to display.

## Output File

`lib/ui/screens/<feature>/<screen_name>.dart`

## Tab Screen Pattern (list view)

Follow `lib/ui/screens/home/tabs/docker_tab.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_unraid/config/spacing.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/ui/widgets/feedback/empty_state.dart';
import 'package:flutter_unraid/ui/widgets/feedback/error_display.dart';
import 'package:flutter_unraid/ui/widgets/feedback/error_snackbar.dart';
import 'package:flutter_unraid/ui/widgets/feedback/loading_indicator.dart';
import 'package:flutter_unraid/ui/widgets/layout/section_header.dart';

class FeatureTab extends StatelessWidget {
  const FeatureTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<FeatureCubit, FeatureState>(
      listenWhen: (_, current) => current is FeatureActionError,
      listener: (context, state) {
        if (state is FeatureActionError) {
          showErrorSnackbar(context, message: state.message);
        }
      },
      child: BlocBuilder<FeatureCubit, FeatureState>(
        buildWhen: (_, current) => current is! FeatureActionError,
        builder: (context, state) {
          final items = switch (state) {
            FeatureLoaded(:final items) => items,
            FeatureActionError(:final items) => items,
            _ => null,
          };

          if (state is FeatureInitial || state is FeatureLoading) {
            return const LoadingIndicator(message: 'Loading...');
          }
          if (state is FeatureError) {
            return ErrorDisplay(
              message: state.message,
              onRetry: () => context.read<FeatureCubit>().refresh(),
            );
          }
          if (items == null || items.isEmpty) {
            return const EmptyState(message: 'No items found.', icon: Icons.inbox_outlined);
          }

          return RefreshIndicator(
            onRefresh: () => context.read<FeatureCubit>().refresh(),
            color: AppColors.unraidOrange,
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              children: [
                SectionHeader(title: 'Title'),
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

## Detail Screen Pattern (pushed via Navigator)

```dart
class FeatureDetailScreen extends StatelessWidget {
  final String itemId;
  const FeatureDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Title')),
      body: BlocBuilder<FeatureCubit, FeatureState>(
        builder: (context, state) => switch (state) {
          FeatureInitial() || FeatureLoading() => const LoadingIndicator(),
          FeatureError(:final message) =>
            ErrorDisplay(message: message, onRetry: () => context.read<FeatureCubit>().load()),
          FeatureLoaded() => _buildContent(context, state),
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
- Navigation: `Navigator.of(context).push(MaterialPageRoute(...))` with `BlocProvider.value` to pass cubit

$ARGUMENTS
