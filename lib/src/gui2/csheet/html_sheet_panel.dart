// Inline HTML character sheet — renders inside the app on all platforms.
//
// Android / iOS  : webview_flutter  (Chromium / WKWebView)
// Windows        : webview_windows  (Edge WebView2 — needs NuGet at build time)
// Linux / macOS  : flutter_html body-content extraction (no native WebView)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:webview_flutter/webview_flutter.dart' as wf;
import 'package:webview_windows/webview_windows.dart' as ww;
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
  // Mobile WebView (Android / iOS)
  wf.WebViewController? _mobileCtrl;

  // Windows WebView (Edge WebView2 via webview_windows)
  ww.WebviewController? _winCtrl;
  bool _winCtrlReady = false;
  String? _pendingHtml; // HTML queued before controller is ready

  // Flutter-html fallback (Linux / macOS)
  String? _currentHtml;

  CharacterFacadeImpl? _lastCharacter;

  @override
  void initState() {
    super.initState();
    currentCharacter.addListener(_onCharacterChanged);
    if (Platform.isAndroid || Platform.isIOS) {
      _mobileCtrl = wf.WebViewController()
        ..setJavaScriptMode(wf.JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white);
    } else if (Platform.isWindows) {
      _initWinWebView();
    }
    final char = currentCharacter.value;
    if (char is CharacterFacadeImpl) _loadSheet(char);
  }

  Future<void> _initWinWebView() async {
    try {
      final ctrl = ww.WebviewController();
      await ctrl.initialize();
      if (!mounted) return;
      _winCtrl = ctrl;
      setState(() => _winCtrlReady = true);
      // Load any HTML that arrived before the controller was ready
      if (_pendingHtml != null) {
        await ctrl.loadStringContent(_pendingHtml!);
        _pendingHtml = null;
      }
    } catch (e) {
      debugPrint('HtmlSheetPanel: Windows WebView init failed: $e');
      // Will fall back to flutter_html
    }
  }

  @override
  void dispose() {
    currentCharacter.removeListener(_onCharacterChanged);
    _winCtrl?.dispose();
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
    if (mounted && _mobileCtrl == null && !_winCtrlReady) {
      setState(() => _currentHtml = null);
    }
    try {
      final html = await Future(() => _generateHtml(pc));
      if (!mounted) return;
      if (_mobileCtrl != null) {
        await _mobileCtrl!.loadHtmlString(html);
      } else if (_winCtrl != null && _winCtrlReady) {
        await _winCtrl!.loadStringContent(html);
      } else if (Platform.isWindows) {
        // Windows controller still initialising — queue the HTML
        _pendingHtml = html;
      } else {
        setState(() => _currentHtml = html);
      }
    } catch (e) {
      debugPrint('HtmlSheetPanel error: $e');
      if (!mounted) return;
      try {
        final html = BuiltinSheetGenerator(pc, loadedDataSet.value).generate();
        if (_mobileCtrl != null) {
          await _mobileCtrl!.loadHtmlString(html);
        } else if (_winCtrl != null && _winCtrlReady) {
          await _winCtrl!.loadStringContent(html);
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

        // Android / iOS
        if (_mobileCtrl != null) {
          return wf.WebViewWidget(controller: _mobileCtrl!);
        }

        // Windows — Edge WebView2
        if (Platform.isWindows) {
          if (_winCtrlReady && _winCtrl != null) {
            return ww.Webview(_winCtrl!);
          }
          return const Center(child: CircularProgressIndicator());
        }

        // Linux / macOS fallback
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
