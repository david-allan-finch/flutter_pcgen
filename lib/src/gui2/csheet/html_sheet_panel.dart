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

  void _loadSheet(CharacterFacadeImpl pc) {
    _lastCharacter = pc;
    try {
      final html = widget.templatePath != null
          ? CharacterExportAction(pc, dataset: loadedDataSet.value)
              .executeFromTemplate(widget.templatePath!)
          : BuiltinSheetGenerator(pc, loadedDataSet.value).generate();
      if (_mobileCtrl != null) {
        _mobileCtrl!.loadHtmlString(html);
      } else {
        if (mounted) setState(() => _currentHtml = html);
      }
    } catch (e) {
      debugPrint('HtmlSheetPanel error: $e');
    }
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
