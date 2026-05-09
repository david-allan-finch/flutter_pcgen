// Inline HTML character sheet — renders inside the app on all platforms.
//
// Android / iOS : webview_flutter  (Chromium WebView)
// Windows       : webview_windows  (Edge WebView2, pre-installed on Win10/11)
// macOS / Linux : open-in-browser fallback

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as wf;
import 'package:webview_windows/webview_windows.dart' as ww;
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
  // Mobile controller (Android/iOS)
  wf.WebViewController? _mobileCtrl;
  // Windows controller
  ww.WebviewController? _winCtrl;
  bool _winReady = false;

  CharacterFacadeImpl? _lastCharacter;
  bool _initialised = false;
  String? _pendingHtml;

  @override
  void initState() {
    super.initState();
    currentCharacter.addListener(_onCharacterChanged);
    _init();
  }

  @override
  void dispose() {
    currentCharacter.removeListener(_onCharacterChanged);
    _winCtrl?.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    if (Platform.isAndroid || Platform.isIOS) {
      _mobileCtrl = wf.WebViewController()
        ..setJavaScriptMode(wf.JavaScriptMode.unrestricted);
    } else if (Platform.isWindows) {
      try {
        final ctrl = ww.WebviewController();
        await ctrl.initialize();
        _winCtrl = ctrl;
        _winReady = true;
      } catch (e) {
        debugPrint('webview_windows init failed: $e');
      }
    }
    _initialised = true;
    if (mounted) setState(() {});

    // Load pending sheet
    final char = currentCharacter.value;
    if (char is CharacterFacadeImpl) _loadSheet(char);
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
      _setHtml(html);
    } catch (e) {
      debugPrint('HtmlSheetPanel._loadSheet error: $e');
    }
  }

  void _setHtml(String html) {
    if (_mobileCtrl != null) {
      _mobileCtrl!.loadHtmlString(html);
    } else if (_winCtrl != null && _winReady) {
      _winCtrl!.loadStringContent(html);
    } else {
      _pendingHtml = html; // will be applied once init completes
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

        if (character is CharacterFacadeImpl &&
            character != _lastCharacter) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _loadSheet(character));
        }

        if (!_initialised) {
          return const Center(child: CircularProgressIndicator());
        }

        // Mobile
        if (_mobileCtrl != null) {
          return wf.WebViewWidget(controller: _mobileCtrl!);
        }

        // Windows
        if (_winCtrl != null && _winReady) {
          return Webview(_winCtrl!);
        }

        // Fallback
        return const _NoWebViewFallback();
      },
    );
  }
}

class _NoWebViewFallback extends StatelessWidget {
  const _NoWebViewFallback();
  @override
  Widget build(BuildContext context) => const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.web_asset_off, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('WebView not available on this platform.',
              style: TextStyle(color: Colors.grey)),
          SizedBox(height: 4),
          Text('Use the "View HTML Sheet" button to open in your browser.',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ]),
      );
}
