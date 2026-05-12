// Inline HTML character sheet — renders inside the app on all platforms.
//
// Android / iOS : webview_flutter  (Chromium WebView)
// Windows       : webview_windows  (Edge WebView2) if NuGet available,
//                 otherwise flutter_html (pure Flutter HTML renderer)
// macOS / Linux : flutter_html

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:webview_flutter/webview_flutter.dart' as wf;
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
  wf.WebViewController? _mobileCtrl;
  CharacterFacadeImpl? _lastCharacter;
  String? _currentHtml;

  static bool get _isMobile => Platform.isAndroid || Platform.isIOS;

  @override
  void initState() {
    super.initState();
    currentCharacter.addListener(_onCharacterChanged);
    if (_isMobile) {
      _mobileCtrl = wf.WebViewController()
        ..setJavaScriptMode(wf.JavaScriptMode.unrestricted);
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
    // Show loading state
    if (mounted) setState(() => _currentHtml = null);
    try {
      // Generate off the UI thread so the app never locks
      final html = await Future(() => _generateHtml(pc));
      debugPrint('SHEET_HTML length=${html.length} first200=${html.substring(0, html.length.clamp(0, 200))}');
      if (!mounted) return;
      if (_mobileCtrl != null) {
        _mobileCtrl!.loadHtmlString(html);
      } else {
        setState(() => _currentHtml = html);
      }
    } catch (e) {
      debugPrint('HtmlSheetPanel error: $e');
      if (!mounted) return;
      try {
        final html = BuiltinSheetGenerator(pc, loadedDataSet.value).generate();
        if (_mobileCtrl != null) {
          _mobileCtrl!.loadHtmlString(html);
        } else {
          setState(() => _currentHtml = html);
        }
      } catch (_) {}
    }
  }

  String _generateHtml(CharacterFacadeImpl pc) {
    // Explicit template path takes priority
    if (widget.templatePath != null) {
      return CharacterExportAction(pc, dataset: loadedDataSet.value)
          .executeFromTemplate(widget.templatePath!);
    }

    // Try the game's default preview sheet (Standard.htm.ftl)
    final previewDir = ConfigurationSettings.getPreviewDir();
    // PREVIEWDIR in 35e miscinfo.lst is 'd20/fantasy', so the sheet is at:
    //   <previewDir>/d20/fantasy/Standard.htm.ftl  (if previewDir = outputsheets/preview)
    // But our copy is at:  preview/d20/fantasy/Standard.htm.ftl
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

    // Fall back to built-in sheet
    return BuiltinSheetGenerator(pc, loadedDataSet.value).generate();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentCharacter,
      builder: (context, character, _) {
        if (character == null) {
          return const Center(
            child: Text('No character selected.',
                style: TextStyle(color: Colors.grey,
                    fontStyle: FontStyle.italic)),
          );
        }
        if (character is CharacterFacadeImpl && character != _lastCharacter) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _loadSheet(character));
        }

        // Mobile: native WebView
        if (_mobileCtrl != null) {
          return wf.WebViewWidget(controller: _mobileCtrl!);
        }

        // Desktop: flutter_html (pure Flutter renderer, no NuGet needed)
        if (_currentHtml != null) {
          return SingleChildScrollView(
            child: Html(data: _currentHtml!),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
