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
import 'package:flutter_pcgen/src/core/system_collections.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';
import 'package:flutter_pcgen/src/gui2/csheet/ftl_widget_renderer.dart';
import 'package:flutter_pcgen/src/gui2/facade/character_facade_impl.dart';
import 'package:flutter_pcgen/src/io/freemarker/character_export_action.dart';
import 'package:flutter_pcgen/src/io/freemarker/ftl_engine.dart';
import 'package:flutter_pcgen/src/io/freemarker/pcgen_token_api.dart';
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

  // Rendered widget — built directly from FTL engine, no HTML intermediate
  Widget? _renderedWidget;
  bool _loading = false;

  CharacterFacadeImpl? _lastCharacter;
  String? _lastRenderKey;

  static bool get _isMobile => Platform.isAndroid || Platform.isIOS;

  @override
  void initState() {
    super.initState();
    _templates    = _discoverTemplates();
    _selectedPath = _defaultTemplatePath();

    currentCharacter.addListener(_onCharacterChanged);
    if (_isMobile && _selectedPath != null) {
      _mobileCtrl = wf.WebViewController()
        ..setJavaScriptMode(wf.JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white);
    }
    final char = currentCharacter.value;
    if (char is CharacterFacadeImpl) {
      _lastCharacter = char;
      char.addListener(_onCharacterModified);
      _reload(char);
    }
  }

  @override
  void dispose() {
    currentCharacter.removeListener(_onCharacterChanged);
    _lastCharacter?.removeListener(_onCharacterModified);
    super.dispose();
  }

  void _onCharacterChanged() {
    final char = currentCharacter.value;
    // Switch the per-character ChangeNotifier listener.
    _lastCharacter?.removeListener(_onCharacterModified);
    if (char is CharacterFacadeImpl) {
      _lastCharacter = char;
      char.addListener(_onCharacterModified);
      _lastRenderKey = null; // force re-render for newly loaded character
      _reload(char);
    } else {
      _lastCharacter = null;
    }
  }

  /// Called whenever the character's own state changes (equip, level, stats…).
  void _onCharacterModified() {
    final char = _lastCharacter;
    if (char == null) return;
    _lastRenderKey = null; // invalidate cache so _reload re-renders
    _reload(char);
  }

  // ─── Template discovery ────────────────────────────────────────────────────

  /// Returns the preview directory from the active game mode's PREVIEWDIR,
  /// falling back to ConfigurationSettings if not set.
  String _resolvePreviewDir() {
    final ds = loadedDataSet.value;
    if (ds != null) {
      final gm = SystemCollections.getGameModeNamed(ds.gameModeStr);
      final gmDir = gm?.getPreviewDir() ?? '';
      if (gmDir.isNotEmpty) {
        // gmDir is relative to the preview root, e.g. "d20/fantasy"
        final base = ConfigurationSettings.getPreviewDir();
        return p.join(base, gmDir);
      }
    }
    return ConfigurationSettings.getPreviewDir();
  }

  /// Finds all .htm.ftl / .html.ftl files under the game mode's preview dir.
  List<_TemplateEntry> _discoverTemplates() {
    final results  = <_TemplateEntry>[];
    final scanDir  = _resolvePreviewDir();
    try {
      final dir = Directory(scanDir);
      if (!dir.existsSync()) return results;
      for (final entity in dir.listSync(recursive: true)) {
        if (entity is File) {
          final name = p.basename(entity.path);
          if (name.endsWith('.htm.ftl') || name.endsWith('.html.ftl')) {
            final rel  = p.relative(entity.path, from: scanDir);
            final stem = name.replaceAll('.htm.ftl', '').replaceAll('.html.ftl', '');
            final sub  = p.dirname(rel);
            final label = (sub == '.' || sub.isEmpty) ? stem : '$stem  ($sub)';
            results.add(_TemplateEntry(path: entity.path, label: label));
          }
        }
      }
    } catch (_) {}
    results.sort((a, b) => a.label.compareTo(b.label));
    return results;
  }

  /// Returns the path of the game mode's default PREVIEWSHEET, or the first
  /// discovered template if PREVIEWSHEET is not set.
  String? _defaultTemplatePath() {
    if (_templates.isEmpty) return null;
    final ds = loadedDataSet.value;
    if (ds != null) {
      final gm     = SystemCollections.getGameModeNamed(ds.gameModeStr);
      final sheet  = gm?.getPreviewSheet() ?? '';
      if (sheet.isNotEmpty) {
        // sheet is a filename like "Standard.htm.ftl" — find matching entry
        final match = _templates.firstWhere(
          (t) => p.basename(t.path) == sheet,
          orElse: () => _templates.first,
        );
        return match.path;
      }
    }
    return _templates.first.path;
  }

  // ─── Rendering ────────────────────────────────────────────────────────────

  Future<void> _reload(CharacterFacadeImpl pc) async {
    _lastCharacter = pc;
    final template = _selectedPath;
    if (template == null) return;

    final key = '${pc.getName()}|$template';
    if (key == _lastRenderKey) return;

    if (mounted) setState(() { _loading = true; _renderedWidget = null; });
    try {
      if (_mobileCtrl != null) {
        // Mobile: WebView needs an HTML string
        final html = await Future(() =>
            CharacterExportAction(pc, dataset: loadedDataSet.value)
                .executeFromTemplate(template));
        if (!mounted || _selectedPath != template) return;
        _lastRenderKey = key;
        await _mobileCtrl!.loadHtmlString(html);
        if (mounted) setState(() => _loading = false);
      } else {
        // Desktop: FTL engine writes directly into FtlWidgetSink — no HTML string
        final widget = await Future(() {
          final ctx  = PcgenTokenContext(pc, loadedDataSet.value);
          ctx.vars['gamemodename'] = pc.getGameMode();
          final sink = FtlWidgetSink(pc: pc);
          FtlEngine().renderFileToSink(template, ctx, sink);
          return sink.build();
        });
        if (!mounted || _selectedPath != template) return;
        _lastRenderKey = key;
        if (mounted) setState(() { _renderedWidget = widget; _loading = false; });
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
                _renderedWidget = null;
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

    // Desktop: widget built directly from FTL engine via FtlWidgetSink
    if (_renderedWidget != null) return _renderedWidget!;

    return const Center(child: CircularProgressIndicator());
  }
}

class _TemplateEntry {
  final String path;
  final String label;
  const _TemplateEntry({required this.path, required this.label});
}
