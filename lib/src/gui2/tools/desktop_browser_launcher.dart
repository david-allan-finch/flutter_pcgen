// Translation of pcgen.gui2.tools.DesktopBrowserLauncher

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Provides a utility method to open files or URIs in the system browser.
///
/// Depends on the `url_launcher` Flutter plugin
/// (https://pub.dev/packages/url_launcher).  Add it to pubspec.yaml:
///
///   dependencies:
///     url_launcher: ^6.0.0
final class DesktopBrowserLauncher {
  DesktopBrowserLauncher._();

  /// Open [file] in the system's default browser.
  ///
  /// Throws [Exception] if the file does not exist or the browser cannot be
  /// launched.
  static Future<void> viewInBrowserFile(File file) async {
    final uri = file.uri;
    await viewInBrowser(uri);
  }

  /// Open [uri] in the system's default browser.
  ///
  /// Shows an error dialog if the URL cannot be launched.
  static Future<void> viewInBrowser(Uri uri, {BuildContext? context}) async {
    final canLaunch = await canLaunchUrl(uri);
    if (canLaunch) {
      await launchUrl(uri);
    } else {
      debugPrint('Unable to browse to $uri');
      if (context != null && context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Browser Error'),
            content: Text('Unable to open URI:\n$uri'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}
