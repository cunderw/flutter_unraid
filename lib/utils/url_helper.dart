import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_unraid/blocs/settings/settings_cubit.dart';
import 'package:flutter_unraid/blocs/settings/settings_state.dart';
import 'package:flutter_unraid/ui/screens/webview/webview_screen.dart';
import 'package:flutter_unraid/utils/log.dart';

/// Opens a URL either in the in-app WebView or in an external browser,
/// based on the user's settings preference.
Future<void> openUrl(
  BuildContext context, {
  required String url,
  required String title,
}) async {
  const tag = 'openUrl';
  final settingsState = context.read<SettingsCubit>().state;
  final openExternally =
      settingsState is SettingsLoaded && settingsState.openLinksExternally;

  if (openExternally) {
    Log.d('Opening externally: $url', tag: tag);
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  } else {
    Log.d('Opening in-app: $url', tag: tag);
    if (context.mounted) {
      WebViewScreen.open(context, url: url, title: title);
    }
  }
}
