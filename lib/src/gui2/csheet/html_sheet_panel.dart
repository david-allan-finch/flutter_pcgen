// Inline HTML character sheet — renders inside the app on all platforms.
//
// Android / iOS : webview_flutter  (Chromium WebView)
// Desktop       : writes HTML to temp file, opens in system browser via url_launcher.
//                 Also shows body content in-app via flutter_html (unstyled fallback).

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart' as wf;
import 'package:flutter_pcgen/src/gui2/app_state.dart';
import 'package:flutter_pcgen/src/gui2/facade/character_facade_impl.dart';
import 'package:flutter_pcgen/src/io/html/builtin_sheet_generator.dart';
import 'package:flutter_pcgen/src/io/freemarker/character_export_action.dart';
import 'package:flutter_pcgen/src/system/configuration_settings.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class HtmlSheetPanel extends StatefulWidget {
  final String? templatePath;
  const HtmlSheetPanel({super.key, this.templatePath});

  @override
  State<HtmlSheetPanel> createState() => _HtmlSheetPanelState();
}

class _HtmlSheetPanelState extends State<HtmlSheetPanel> {
  wf.WebViewController? _mobileCtrl;
  CharacterFacadeImpl? _lastCharacter;
  String? _currentHtml;   // full HTML (for browser export)
  String? _tempHtmlPath;  // path of last written temp file

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
    if (mounted) setState(() { _currentHtml = null; _tempHtmlPath = null; });
    try {
      final html = await Future(() => _generateHtml(pc));
      if (!mounted) return;
      if (_mobileCtrl != null) {
        _mobileCtrl!.loadHtmlString(html);
      } else {
        // Write to temp file for "Open in Browser"
        final dir = await getTemporaryDirectory();
        final safeName = pc.getName().replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
        final path = p.join(dir.path, 'pcgen_sheet_$safeName.html');
        await File(path).writeAsString(html);
        if (mounted) setState(() { _currentHtml = html; _tempHtmlPath = path; });
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

  Future<void> _openInBrowser() async {
    final path = _tempHtmlPath;
    if (path == null) return;
    final uri = Uri.file(path);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Extract body content from a full HTML document for flutter_html.
  String _bodyContent(String html) {
    final bodyStart = html.indexOf('<body');
    final bodyEnd   = html.lastIndexOf('</body>');
    if (bodyStart >= 0 && bodyEnd > bodyStart) {
      final contentStart = html.indexOf('>', bodyStart) + 1;
      return html.substring(contentStart, bodyEnd);
    }
    return html;
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

        // Mobile: native WebView
        if (_mobileCtrl != null) {
          return wf.WebViewWidget(controller: _mobileCtrl!);
        }

        // Desktop: in-app preview (body content only) + Open in Browser button
        if (_currentHtml != null) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: Html(data: _bodyContent(_currentHtml!)),
              ),
              Positioned(
                top: 8, right: 8,
                child: ElevatedButton.icon(
                  onPressed: _openInBrowser,
                  icon: const Icon(Icons.open_in_browser, size: 16),
                  label: const Text('Open in Browser'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                ),
              ),
            ],
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
