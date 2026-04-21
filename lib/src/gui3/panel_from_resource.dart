// Translation of pcgen.gui3.PanelFromResource / JFXPanelFromResource

import 'package:flutter/material.dart';

/// Flutter equivalent of JavaFX's JFXPanelFromResource — loads a widget
/// defined by a resource key/asset path. In Flutter this simply returns a
/// placeholder; the actual panel widgets are constructed directly.
abstract class PanelFromResource extends StatelessWidget {
  const PanelFromResource({super.key});

  /// The resource identifier (e.g., asset path or route name).
  String get resourceName;
}

/// Simple HTML panel backed by a string of HTML content.
class SimpleHtmlPanel extends StatelessWidget {
  final String htmlContent;

  const SimpleHtmlPanel({super.key, required this.htmlContent});

  @override
  Widget build(BuildContext context) {
    // In a real implementation, use a webview or html rendering package.
    // For now, strip tags and display as plain text.
    final plain = htmlContent
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Text(plain),
    );
  }
}
