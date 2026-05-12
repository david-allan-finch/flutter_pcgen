// Inline HTML character sheet — renders inside the app on all platforms.
//
// Android / iOS  : webview_flutter  (native WebView for FTL template output)
// Desktop        : flutter_html renders the BuiltinSheetGenerator output
//                  (inline-styles-only HTML, no external CSS needed)

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
        ..setJavaScriptMode(wf.JavaScriptMode.unrestricted)
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
    if (mounted) setState(() => _currentHtml = null);
    try {
      final html = await Future(() => _generateHtml(pc));
      if (!mounted) return;
      if (_mobileCtrl != null) {
        await _mobileCtrl!.loadHtmlString(html);
      } else {
        setState(() => _currentHtml = html);
      }
    } catch (e) {
      debugPrint('HtmlSheetPanel error: $e');
    }
  }

  String _generateHtml(CharacterFacadeImpl pc) {
    // On mobile try FTL template first (full browser WebView can handle it)
    if (_isMobile && widget.templatePath != null) {
      return CharacterExportAction(pc, dataset: loadedDataSet.value)
          .executeFromTemplate(widget.templatePath!);
    }
    if (_isMobile) {
      final previewDir = ConfigurationSettings.getPreviewDir();
      for (final path in [
        p.join(previewDir, 'Standard.htm.ftl'),
        p.join(previewDir, 'd20', 'fantasy', 'Standard.htm.ftl'),
      ]) {
        if (File(path).existsSync()) {
          return CharacterExportAction(pc, dataset: loadedDataSet.value)
              .executeFromTemplate(path);
        }
      }
    }
    // Desktop: use the built-in generator (inline styles, flutter_html compatible)
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

        // Mobile: native WebView (FTL template output)
        if (_mobileCtrl != null) {
          return wf.WebViewWidget(controller: _mobileCtrl!);
        }

        // Desktop: flutter_html (inline-styled HTML fragment)
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
