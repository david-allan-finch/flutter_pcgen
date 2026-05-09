// Inline HTML character sheet panel.
// Renders the built-in (or FTL-processed) HTML sheet inside the app using
// a WebView — equivalent to how Java PCGen shows the sheet tab.

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';
import 'package:flutter_pcgen/src/gui2/facade/character_facade_impl.dart';
import 'package:flutter_pcgen/src/io/html/builtin_sheet_generator.dart';
import 'package:flutter_pcgen/src/io/freemarker/character_export_action.dart';

class HtmlSheetPanel extends StatefulWidget {
  /// Optional path to an external .htm.ftl template. If null, uses the built-in sheet.
  final String? templatePath;

  const HtmlSheetPanel({super.key, this.templatePath});

  @override
  State<HtmlSheetPanel> createState() => _HtmlSheetPanelState();
}

class _HtmlSheetPanelState extends State<HtmlSheetPanel> {
  WebViewController? _controller;
  CharacterFacadeImpl? _lastCharacter;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    currentCharacter.addListener(_onCharacterChanged);
    _initWebView();
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

  void _initWebView() {
    final ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _loading = false),
        onWebResourceError: (e) => setState(() {
          _loading = false;
          _error = e.description;
        }),
      ));
    setState(() => _controller = ctrl);

    final char = currentCharacter.value;
    if (char is CharacterFacadeImpl) {
      _loadSheet(char);
    }
  }

  void _loadSheet(CharacterFacadeImpl pc) {
    final ctrl = _controller;
    if (ctrl == null) return;
    _lastCharacter = pc;
    setState(() { _loading = true; _error = null; });

    try {
      final String html;
      if (widget.templatePath != null) {
        html = CharacterExportAction(pc, dataset: loadedDataSet.value)
            .executeFromTemplate(widget.templatePath!);
      } else {
        html = BuiltinSheetGenerator(pc, loadedDataSet.value).generate();
      }
      ctrl.loadHtmlString(html, baseUrl: 'about:blank');
    } catch (e) {
      setState(() { _loading = false; _error = e.toString(); });
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
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          );
        }

        if (character is CharacterFacadeImpl && character != _lastCharacter) {
          // Schedule sheet reload after build
          WidgetsBinding.instance.addPostFrameCallback((_) => _loadSheet(character));
        }

        if (_error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                Text('Sheet render error: $_error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    if (character is CharacterFacadeImpl) _loadSheet(character);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (_controller == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            WebViewWidget(controller: _controller!),
            if (_loading)
              const Center(child: CircularProgressIndicator()),
          ],
        );
      },
    );
  }
}
