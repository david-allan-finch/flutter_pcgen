// Inline HTML character sheet — renders inside the app on all platforms.
//
// Android / iOS / Windows : webview_flutter  (native WebView)
// Linux / macOS           : flutter_html body extraction (no WebView2 available)

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';
import 'package:flutter_pcgen/src/gui2/facade/character_facade_impl.dart';
import 'package:flutter_pcgen/src/io/html/builtin_sheet_generator.dart';
import 'package:flutter_pcgen/src/io/freemarker/character_export_action.dart';
import 'package:flutter_pcgen/src/system/configuration_settings.dart';
import 'package:path/path.dart' as p;

class HtmlSheetPanel extends StatefulWidget {
  final String? templatePath;
  const HtmlSheetPanel({super.key, this.templatePath});

  @override
  State<HtmlSheetPanel> createState() => _HtmlSheetPanelState();
}

class _HtmlSheetPanelState extends State<HtmlSheetPanel> {
  WebViewController? _webCtrl;
  CharacterFacadeImpl? _lastCharacter;
  String? _currentHtml; // used only on platforms without WebView

  // Use native WebView on Android, iOS, and Windows.
  // Linux/macOS fall back to flutter_html (no WebView2 available there).
  static bool get _useWebView =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isWindows);

  @override
  void initState() {
    super.initState();
    currentCharacter.addListener(_onCharacterChanged);
    if (_useWebView) {
      _webCtrl = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white);
    }
    final char = currentCharacter.value;
    if (char is CharacterFacadeImpl) _loadSheet(char);
  }

  @override
  void dispose() {
    currentCharacter.removeListener(_onCharacterChanged);
    super.dispose();
  }

  void _onCharacterChanged() {
    final char = currentCharacter.value;
    if (char is CharacterFacadeImpl && char != _lastCharacter) {
      _loadSheet(char);
    }
  }

  Future<void> _loadSheet(CharacterFacadeImpl pc) async {
    _lastCharacter = pc;
    if (mounted && !_useWebView) setState(() => _currentHtml = null);
    try {
      final html = await Future(() => _generateHtml(pc));
      if (!mounted) return;
      if (_webCtrl != null) {
        await _webCtrl!.loadHtmlString(html);
      } else {
        setState(() => _currentHtml = html);
      }
    } catch (e) {
      debugPrint('HtmlSheetPanel error: $e');
      if (!mounted) return;
      try {
        final html = BuiltinSheetGenerator(pc, loadedDataSet.value).generate();
        if (_webCtrl != null) {
          await _webCtrl!.loadHtmlString(html);
        } else {
          setState(() => _currentHtml = html);
        }
      } catch (_) {}
    }
  }

  String _generateHtml(CharacterFacadeImpl pc) {
    if (widget.templatePath != null) {
      return CharacterExportAction(pc, dataset: loadedDataSet.value)
          .executeFromTemplate(widget.templatePath!);
    }
    final previewDir = ConfigurationSettings.getPreviewDir();
    final candidates = [
      p.join(previewDir, 'Standard.htm.ftl'),
      p.join(previewDir, 'd20', 'fantasy', 'Standard.htm.ftl'),
    ];
    for (final path in candidates) {
      if (File(path).existsSync()) {
        return CharacterExportAction(pc, dataset: loadedDataSet.value)
            .executeFromTemplate(path);
      }
    }
    return BuiltinSheetGenerator(pc, loadedDataSet.value).generate();
  }

  /// Extract body content from a full HTML document for flutter_html fallback.
  String _bodyContent(String html) {
    final bodyStart = html.indexOf('<body');
    final bodyEnd   = html.lastIndexOf('</body>');
    if (bodyStart >= 0 && bodyEnd > bodyStart) {
      final contentStart = html.indexOf('>', bodyStart) + 1;
      return html.substring(contentStart, bodyEnd);
    }
    return html;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentCharacter,
      builder: (context, character, _) {
        if (character == null) {
          return const Center(
            child: Text('No character selected.',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          );
        }
        if (character is CharacterFacadeImpl && character != _lastCharacter) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _loadSheet(character));
        }

        // Native WebView (Android, iOS, Windows)
        if (_webCtrl != null) {
          return WebViewWidget(controller: _webCtrl!);
        }

        // Fallback: flutter_html with body content only (Linux/macOS)
        if (_currentHtml != null) {
          return SingleChildScrollView(
            child: Html(data: _bodyContent(_currentHtml!)),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
