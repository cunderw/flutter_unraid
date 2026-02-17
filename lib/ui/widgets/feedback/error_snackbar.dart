import 'package:flutter/material.dart';

import 'package:flutter_unraid/config/theme.dart';

/// Shows a themed, dismissable error snackbar.
void showErrorSnackbar(BuildContext context, {required String message}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.card,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        showCloseIcon: true,
        closeIconColor: AppColors.unraidOrange,
      ),
    );
}
