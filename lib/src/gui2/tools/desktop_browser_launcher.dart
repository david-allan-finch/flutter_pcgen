//
// Copyright 2012 Vincent Lhote
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
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
