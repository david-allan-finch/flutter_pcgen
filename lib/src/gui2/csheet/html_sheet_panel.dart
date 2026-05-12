// Character sheet panel — renders inside the app on all platforms.
//
// Toolbar lets the user pick:
//   "Native"      → CharacterSheetWidget (Flutter widgets, always works)
//   <template>    → FTL engine → HTML → flutter_html body extraction
//                   + "Open in Browser" button for full styled view
//
// Mobile (Android / iOS) uses a native WebView for FTL templates.

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

/// Sentinel value meaning "use the native Flutter widget sheet".
const _kNative = '__native__';

class _HtmlSheetPanelState extends State<HtmlSheetPanel> {
  // Mobile WebView
  wf.WebViewController? _mobileCtrl;

  // Template selection — null = first load pending
  String _selectedTemplate = _kNative;
  List<_TemplateEntry> _templates = [];

  // Generated HTML (FTL mode desktop)
  String? _currentHtml;
  String? _tempHtmlPath;
  bool _loading = false;

  CharacterFacadeImpl? _lastCharacter;
  String? _lastTemplate;

  static bool get _isMobile => Platform.isAndroid || Platform.isIOS;

  @override
  void initState() {
    super.initState();
    _templates = _discoverTemplates();
    // Default: prefer Standard.htm.ftl if available, otherwise native
    if (_templates.isNotEmpty) {
      _selectedTemplate = _templates.first.path;
    }
    currentCharacter.addListener(_onCharacterChanged);
    if (_isMobile) {
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
    _scanDir(Directory(previewDir), results);
    return results;
  }

  void _scanDir(Directory dir, List<_TemplateEntry> out) {
    if (!dir.existsSync()) return;
    try {
      for (final entity in dir.listSync(recursive: true)) {
        if (entity is File) {
          final name = p.basename(entity.path);
          // Only top-level sheet templates, not #include helpers
          if (name.endsWith('.htm.ftl') || name.endsWith('.html.ftl')) {
            out.add(_TemplateEntry(
              path: entity.path,
              label: name.replaceAll('.htm.ftl', '').replaceAll('.html.ftl', ''),
            ));
          }
        }
      }
    } catch (_) {}
    out.sort((a, b) => a.label.compareTo(b.label));
  }

  // ─── Rendering ────────────────────────────────────────────────────────────

  Future<void> _reload(CharacterFacadeImpl pc) async {
    _lastCharacter = pc;
    _lastTemplate  = _selectedTemplate;

    if (_selectedTemplate == _kNative) {
      if (mounted) setState(() { _currentHtml = null; _loading = false; });
      return;
    }

    if (mounted) setState(() { _loading = true; _currentHtml = null; });
    try {
      final html = await Future(() => CharacterExportAction(pc,
              dataset: loadedDataSet.value)
          .executeFromTemplate(_selectedTemplate));

      if (!mounted || _lastTemplate != _selectedTemplate) return;

      if (_mobileCtrl != null) {
        await _mobileCtrl!.loadHtmlString(html);
        if (mounted) setState(() => _loading = false);
      } else {
        // Write full HTML to temp file for "Open in Browser"
        final dir  = await getTemporaryDirectory();
        final safe = pc.getName().replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
        final path = p.join(dir.path, 'pcgen_$safe.html');
        await File(path).writeAsString(html);
        if (mounted) setState(() {
          _currentHtml   = html;
          _tempHtmlPath  = path;
          _loading       = false;
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

        return Column(children: [
          _buildToolbar(),
          Expanded(child: _buildBody(character)),
        ]);
      },
    );
  }

  Widget _buildToolbar() {
    final items = <DropdownMenuItem<String>>[
      const DropdownMenuItem(value: _kNative,
          child: Text('Native view', style: TextStyle(fontSize: 13))),
      if (_templates.isNotEmpty)
        const DropdownMenuItem(enabled: false, value: '',
            child: Divider(height: 1)),
      ..._templates.map((t) => DropdownMenuItem(
          value: t.path,
          child: Text(t.label, style: const TextStyle(fontSize: 13)))),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: const Color(0xFF37474F),
      child: Row(children: [
        const Text('Sheet:', style: TextStyle(color: Colors.white, fontSize: 12)),
        const SizedBox(width: 8),
        Expanded(child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedTemplate,
            dropdownColor: const Color(0xFF455A64),
            style: const TextStyle(color: Colors.white, fontSize: 13),
            iconEnabledColor: Colors.white,
            isExpanded: true,
            items: items,
            onChanged: (val) {
              if (val == null || val.isEmpty) return;
              setState(() {
                _selectedTemplate = val;
                _currentHtml = null;
                _tempHtmlPath = null;
              });
              final char = currentCharacter.value;
              if (char is CharacterFacadeImpl) _reload(char);
            },
          ),
        )),
        if (_selectedTemplate != _kNative && _tempHtmlPath != null)
          IconButton(
            icon: const Icon(Icons.open_in_browser, color: Colors.white, size: 20),
            tooltip: 'Open in Browser',
            onPressed: _openInBrowser,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            constraints: const BoxConstraints(),
          ),
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

  Widget _buildBody(dynamic character) {
    // Mobile WebView (FTL templates)
    if (_mobileCtrl != null && _selectedTemplate != _kNative) {
      return wf.WebViewWidget(controller: _mobileCtrl!);
    }

    // Native Flutter widget sheet
    if (_selectedTemplate == _kNative && character is CharacterFacadeImpl) {
      return CharacterSheetWidget(
        key: ValueKey(character.getName()),
        pc: character,
        dataset: loadedDataSet.value,
      );
    }

    // FTL template → flutter_html (desktop)
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
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
