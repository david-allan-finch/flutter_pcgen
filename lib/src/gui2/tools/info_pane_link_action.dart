// Translation of pcgen.gui2.tools.InfoPaneLinkAction

import 'package:flutter/material.dart';

import 'desktop_browser_launcher.dart';
import 'info_pane.dart';

/// Handles hyperlink taps inside an [InfoPane] by opening the URL in the
/// system browser.
///
/// Usage:
/// ```dart
/// final action = InfoPaneLinkAction(context: context);
/// InfoPane(onLinkTap: action.onLinkTap, ...);
/// ```
class InfoPaneLinkAction {
  /// A [BuildContext] used to show error dialogs.
  final BuildContext context;

  const InfoPaneLinkAction({required this.context});

  /// Install this handler on [infoPane] by returning a configured [InfoPane].
  ///
  /// Because Flutter uses callbacks rather than listeners, the idiomatic way
  /// to "install" is to pass [onLinkTap] directly to the [InfoPane] widget.
  HyperlinkCallback get onLinkTap => _handleLinkTap;

  void _handleLinkTap(String href) {
    final uri = Uri.tryParse(href);
    if (uri == null) {
      _showError('Invalid URL: $href');
      return;
    }
    DesktopBrowserLauncher.viewInBrowser(uri, context: context).catchError(
      (Object error) {
        debugPrint('Failed to open URL $href: $error');
        _showError('Failed to open URL $href');
      },
    );
  }

  void _showError(String message) {
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Browser Error'),
        content: Text(message),
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
