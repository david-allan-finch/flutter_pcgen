// Translation of pcgen.gui3.GuiUtility

import 'package:flutter/material.dart';

/// General GUI utility helpers.
class GuiUtility {
  GuiUtility._();

  /// Run [fn] on the next UI frame (equivalent to Platform.runLater in JavaFX).
  static void runLater(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) => fn());
  }

  /// Shows an error dialog.
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog; returns true if the user confirms.
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'OK',
    String cancelLabel = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
