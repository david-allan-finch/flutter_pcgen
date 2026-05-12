// Character sheet panel — renders inside the app on all platforms.
//
// Mobile (Android / iOS) : webview_flutter with FTL template (full browser render)
// Desktop                : CharacterSheetWidget (pure Flutter, no HTML renderer)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as wf;
import 'package:flutter_pcgen/src/gui2/app_state.dart';
import 'package:flutter_pcgen/src/gui2/csheet/character_sheet_widget.dart';
import 'package:flutter_pcgen/src/gui2/facade/character_facade_impl.dart';
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

  static bool get _isMobile => Platform.isAndroid || Platform.isIOS;

  @override
  void initState() {
    super.initState();
    currentCharacter.addListener(_onCharacterChanged);
    if (_isMobile) {
      _mobileCtrl = wf.WebViewController()
        ..setJavaScriptMode(wf.JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white);
      final char = currentCharacter.value;
      if (char is CharacterFacadeImpl) _loadMobileSheet(char);
    }
  }

  @override
  void dispose() {
    currentCharacter.removeListener(_onCharacterChanged);
    super.dispose();
  }

  void _onCharacterChanged() {
    final char = currentCharacter.value;
    if (char is CharacterFacadeImpl && char != _lastCharacter) {
      _lastCharacter = char;
      if (_isMobile) _loadMobileSheet(char);
      // Desktop updates via ValueListenableBuilder rebuild — no state needed.
    }
  }

  Future<void> _loadMobileSheet(CharacterFacadeImpl pc) async {
    _lastCharacter = pc;
    try {
      final html = await Future(() => _generateFtlHtml(pc));
      if (mounted) await _mobileCtrl!.loadHtmlString(html);
    } catch (e) {
      debugPrint('HtmlSheetPanel mobile error: $e');
    }
  }

  String _generateFtlHtml(CharacterFacadeImpl pc) {
    if (widget.templatePath != null) {
      return CharacterExportAction(pc, dataset: loadedDataSet.value)
          .executeFromTemplate(widget.templatePath!);
    }
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
    return '<html><body><p>No template found.</p></body></html>';
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

        // Mobile: native WebView with FTL template
        if (_mobileCtrl != null) {
          return wf.WebViewWidget(controller: _mobileCtrl!);
        }

        // Desktop: pure Flutter widget sheet (no HTML renderer needed)
        if (character is CharacterFacadeImpl) {
          return CharacterSheetWidget(
            key: ValueKey(character.getName()),
            pc: character,
            dataset: loadedDataSet.value,
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
