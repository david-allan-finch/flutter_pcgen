// Character sheet panel — FTL template selector.
//
// Toolbar dropdown lists all .htm.ftl files in the preview directory.
// Selected template is rendered by the FTL engine and shown in-app via
// flutter_html (body content). "Open in Browser" button gives full styled view.
// Falls back to the native Flutter widget sheet if no templates are found.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart' as wf;
import 'package:flutter_pcgen/src/gui2/app_state.dart';
import 'package:flutter_pcgen/src/gui2/csheet/character_sheet_widget.dart';
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
  wf.WebViewController? _mobileCtrl;

  List<_TemplateEntry> _templates = [];
  String? _selectedPath;   // null = native fallback (no templates found)

  String? _currentHtml;
  String? _tempHtmlPath;
  bool _loading = false;

  CharacterFacadeImpl? _lastCharacter;
  String? _lastRenderedKey; // character+template key to avoid duplicate renders

  static bool get _isMobile => Platform.isAndroid || Platform.isIOS;

  @override
  void initState() {
    super.initState();
    _templates = _discoverTemplates();
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

  // ─── Template discovery ───────────────────────────────────────────────────

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

    // No template → show native widget (no loading needed)
    if (template == null) {
      if (mounted) setState(() { _currentHtml = null; _loading = false; });
      return;
    }

    final renderKey = '${pc.getName()}|$template';
    if (renderKey == _lastRenderedKey) return;

    if (mounted) setState(() { _loading = true; _currentHtml = null; });
    try {
      final html = await Future(() =>
          CharacterExportAction(pc, dataset: loadedDataSet.value)
              .executeFromTemplate(template));

      if (!mounted || _selectedPath != template) return;
      _lastRenderedKey = renderKey;

      if (_mobileCtrl != null) {
        await _mobileCtrl!.loadHtmlString(html);
        if (mounted) setState(() => _loading = false);
      } else {
        final dir  = await getTemporaryDirectory();
        final safe = pc.getName().replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
        final path = p.join(dir.path, 'pcgen_$safe.html');
        await File(path).writeAsString(html);
        if (mounted) setState(() {
          _currentHtml  = html;
          _tempHtmlPath = path;
          _loading      = false;
        });
      }
    } catch (e) {
      debugPrint('HtmlSheetPanel FTL error: $e');
      if (mounted) setState(() => _loading = false);
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

  String _bodyContent(String html) {
    final s = html.indexOf('<body');
    final e = html.lastIndexOf('</body>');
    if (s >= 0 && e > s) return html.substring(html.indexOf('>', s) + 1, e);
    return html;
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

        // No templates found → native widget only, no toolbar
        if (_templates.isEmpty) {
          if (character is CharacterFacadeImpl) {
            return CharacterSheetWidget(
              key: ValueKey(character.getName()),
              pc: character,
              dataset: loadedDataSet.value,
            );
          }
          return const Center(child: CircularProgressIndicator());
        }

        return Column(children: [
          _buildToolbar(),
          Expanded(child: _buildBody(character)),
        ]);
      },
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: const Color(0xFF37474F),
      child: Row(children: [
        const Text('Template:', style: TextStyle(color: Colors.white70, fontSize: 12)),
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
              child: Text(t.label, style: const TextStyle(fontSize: 13)),
            )).toList(),
            onChanged: (val) {
              if (val == null) return;
              setState(() {
                _selectedPath  = val;
                _currentHtml   = null;
                _tempHtmlPath  = null;
                _lastRenderedKey = null;
              });
              final char = currentCharacter.value;
              if (char is CharacterFacadeImpl) _reload(char);
            },
          ),
        )),
        if (_tempHtmlPath != null)
          IconButton(
            icon: const Icon(Icons.open_in_browser, color: Colors.white, size: 20),
            tooltip: 'Open in Browser (full styling)',
            onPressed: _openInBrowser,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            constraints: const BoxConstraints(),
          ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
          ),
      ]),
    );
  }

  Widget _buildBody(dynamic character) {
    // Mobile: native WebView
    if (_mobileCtrl != null) {
      return wf.WebViewWidget(controller: _mobileCtrl!);
    }

    // Loading
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // FTL rendered HTML (desktop: flutter_html body extract)
    if (_currentHtml != null) {
      return SingleChildScrollView(
        child: Html(data: _bodyContent(_currentHtml!)),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }
}

class _TemplateEntry {
  final String path;
  final String label;
  const _TemplateEntry({required this.path, required this.label});
}
