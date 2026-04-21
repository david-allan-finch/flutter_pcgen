//
// Copyright 2008 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.tools.InfoPane

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

/// Callback invoked when the user taps a hyperlink inside an [InfoPane].
typedef HyperlinkCallback = void Function(String href);

/// A scrollable pane that displays HTML content inside a titled border.
///
/// Equivalent to the Swing InfoPane (a JScrollPane containing a JTextPane with
/// content type `text/html`).
///
/// HTML rendering is delegated to the `flutter_widget_from_html_core` package.
/// Add it to pubspec.yaml:
///
///   dependencies:
///     flutter_widget_from_html_core: ^0.10.0
///
/// If `flutter_widget_from_html_core` is not available you can substitute the
/// [Text] widget fallback by changing [_buildHtmlContent].
class InfoPane extends StatefulWidget {
  /// Initial title shown in the titled border.  Strings starting with `in_`
  /// are treated as localisation keys; in Dart you should resolve them before
  /// passing them in.
  final String title;

  /// Initial HTML content.
  final String initialText;

  /// Called when the user taps a hyperlink.
  final HyperlinkCallback? onLinkTap;

  const InfoPane({
    super.key,
    this.title = 'Source Info',
    this.initialText = '',
    this.onLinkTap,
  });

  @override
  State<InfoPane> createState() => InfoPaneState();
}

class InfoPaneState extends State<InfoPane> {
  late String _title;
  late String _htmlText;

  @override
  void initState() {
    super.initState();
    _title = widget.title;
    _htmlText = widget.initialText;
  }

  // ---------------------------------------------------------------------------
  // Public API (mirrors Java methods)
  // ---------------------------------------------------------------------------

  String getTitle() => _title;

  void setTitle(String title) {
    setState(() => _title = title);
  }

  void setText(String text) {
    setState(() => _htmlText = text);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 300, minHeight: 200),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Titled border header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.dividerColor),
              ),
            ),
            child: Text(
              _title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall,
            ),
          ),
          // Scrollable HTML content
          Expanded(
            child: Scrollbar(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: _buildHtmlContent(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHtmlContent(BuildContext context) {
    if (_htmlText.isEmpty) {
      return const SizedBox.shrink();
    }
    return HtmlWidget(
      _htmlText,
      onTapUrl: (href) {
        widget.onLinkTap?.call(href);
        return true;
      },
    );
  }
}
