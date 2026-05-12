// Character sheet panel.
//
// Toolbar dropdown lists all .htm.ftl files found in the preview directory.
// Selecting one runs our FTL engine on that template, then FtlWidgetRenderer
// converts the output into native Flutter widgets — no HTML shown in the app.
//
// Mobile (Android/iOS) uses a WebView for richer rendering.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:webview_flutter/webview_flutter.dart' as wf;
import 'package:flutter_pcgen/src/gui2/app_state.dart';
import 'package:flutter_pcgen/src/gui2/csheet/ftl_widget_renderer.dart';
import 'package:flutter_pcgen/src/gui2/facade/character_facade_impl.dart';
import 'package:flutter_pcgen/src/io/freemarker/character_export_action.dart';
import 'package:flutter_pcgen/src/system/configuration_settings.dart';

class HtmlSheetPanel extends StatefulWidget {
  final String? templatePath;
  const HtmlSheetPanel({super.key, this.templatePath});

  @override
  State<HtmlSheetPanel> createState() => _HtmlSheetPanelState();
}

class _HtmlSheetPanelState extends State<HtmlSheetPanel> {
  // Mobile WebView (Android/iOS)
  wf.WebViewController? _mobileCtrl;

  // Available templates and current selection
  List<_TemplateEntry> _templates = [];
  String? _selectedPath;

  // Rendered HTML from FTL engine (desktop: converted to widgets)
  String? _renderedHtml;
  bool _loading = false;

  CharacterFacadeImpl? _lastCharacter;
  String? _lastRenderKey;

  static bool get _isMobile => Platform.isAndroid || Platform.isIOS;

  @override
  void initState() {
    super.initState();
    _templates    = _discoverTemplates();
    _selectedPath = _templates.isNotEmpty ? _templates.first.path : null;

    currentCharacter.addListener(_onCharacterChanged);
    if (_isMobile && _selectedPath != null) {
      _mobileCtrl = wf.WebViewController()
        ..setJavaScriptMode(wf.JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white);
    }
    final char = currentCharacter.value;
    if (char is CharacterFacadeImpl) _reload(char);
  }

  @override
  void dispose() {
    currentCharacter.removeListener(_onCharacterChanged);
    super.dispose();
  }

  void _onCharacterChanged() {
    final char = currentCharacter.value;
    if (char is CharacterFacadeImpl) _reload(char);
  }

  // ─── Template discovery ────────────────────────────────────────────────────

  List<_TemplateEntry> _discoverTemplates() {
    final results = <_TemplateEntry>[];
    final previewDir = ConfigurationSettings.getPreviewDir();
    try {
      final dir = Directory(previewDir);
      if (!dir.existsSync()) return results;
      for (final entity in dir.listSync(recursive: true)) {
        if (entity is File) {
          final name = p.basename(entity.path);
          if (name.endsWith('.htm.ftl') || name.endsWith('.html.ftl')) {
            results.add(_TemplateEntry(
              path: entity.path,
              label: name.replaceAll('.htm.ftl', '').replaceAll('.html.ftl', ''),
            ));
          }
        }
      }
    } catch (_) {}
    results.sort((a, b) => a.label.compareTo(b.label));
    return results;
  }

  // ─── Rendering ────────────────────────────────────────────────────────────

  Future<void> _reload(CharacterFacadeImpl pc) async {
    _lastCharacter = pc;
    final template = _selectedPath;
    if (template == null) return;

    final key = '${pc.getName()}|$template';
    if (key == _lastRenderKey) return;

    if (mounted) setState(() { _loading = true; _renderedHtml = null; });
    try {
      final html = await Future(() =>
          CharacterExportAction(pc, dataset: loadedDataSet.value)
              .executeFromTemplate(template));

      if (!mounted || _selectedPath != template) return;
      _lastRenderKey = key;

      if (_mobileCtrl != null) {
        await _mobileCtrl!.loadHtmlString(html);
        if (mounted) setState(() => _loading = false);
      } else {
        if (mounted) setState(() { _renderedHtml = html; _loading = false; });
      }
    } catch (e) {
      debugPrint('HtmlSheetPanel FTL error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

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
          WidgetsBinding.instance.addPostFrameCallback((_) => _reload(character));
        }

        if (_templates.isEmpty) {
          return const Center(
            child: Text('No .htm.ftl templates found in preview directory.',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          );
        }

        return Column(children: [
          _buildToolbar(),
          Expanded(child: _buildBody()),
        ]);
      },
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      color: const Color(0xFF37474F),
      child: Row(children: [
        const Text('Template:',
            style: TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(width: 8),
        Expanded(child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedPath,
            dropdownColor: const Color(0xFF455A64),
            style: const TextStyle(color: Colors.white, fontSize: 13),
            iconEnabledColor: Colors.white,
            isExpanded: true,
            items: _templates.map((t) => DropdownMenuItem(
              value: t.path,
              child: Text(t.label),
            )).toList(),
            onChanged: (val) {
              if (val == null) return;
              setState(() {
                _selectedPath   = val;
                _renderedHtml   = null;
                _lastRenderKey  = null;
              });
              final char = currentCharacter.value;
              if (char is CharacterFacadeImpl) _reload(char);
            },
          ),
        )),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white)),
          ),
      ]),
    );
  }

  Widget _buildBody() {
    // Mobile: native WebView
    if (_mobileCtrl != null) {
      return wf.WebViewWidget(controller: _mobileCtrl!);
    }

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Desktop: FTL HTML → Flutter widgets via FtlWidgetRenderer
    if (_renderedHtml != null) {
      return FtlWidgetRenderer.render(_renderedHtml!);
    }

    return const Center(child: CircularProgressIndicator());
  }
}

class _TemplateEntry {
  final String path;
  final String label;
  const _TemplateEntry({required this.path, required this.label});
}
