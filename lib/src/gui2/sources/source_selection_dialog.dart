//
// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// Translation of pcgen.gui2.sources.SourceSelectionDialog

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/core/campaign.dart';
import 'package:flutter_pcgen/src/core/globals.dart';
import 'package:flutter_pcgen/src/gui2/sources/advanced_source_selection_panel.dart';

/// Dialog for selecting game sources (books/settings) to load.
///
/// [onLoad] is called with the user's chosen [Campaign] list and the resolved
/// game-mode name when the Load button is pressed.
class SourceSelectionDialog extends StatefulWidget {
  final dynamic uiContext;
  final Future<void> Function(List<Campaign> campaigns, String gameModeName)
      onLoad;

  const SourceSelectionDialog({
    super.key,
    required this.uiContext,
    required this.onLoad,
  });

  static bool skipSourceSelection() => false;

  @override
  State<SourceSelectionDialog> createState() => _SourceSelectionDialogState();
}

class _SourceSelectionDialogState extends State<SourceSelectionDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<Campaign> _selectedCampaigns = [];
  String _gameModeName = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onSelectionChanged(List<Campaign> campaigns, String gameModeName) {
    setState(() {
      _selectedCampaigns = campaigns;
      _gameModeName = gameModeName;
    });
  }

  Future<void> _handleLoad() async {
    if (_selectedCampaigns.isEmpty) return;
    setState(() => _loading = true);
    try {
      await widget.onLoad(_selectedCampaigns, _gameModeName);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Load error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                'Source Selection',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              // Tab bar
              TabBar(
                controller: _tabController,
                tabs: const [Tab(text: 'Basic'), Tab(text: 'Advanced')],
              ),
              // Tab content — takes remaining space
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _BasicPresetsPanel(onSelected: _onSelectionChanged),
                    AdvancedSourceSelectionPanel(
                      onSelectionChanged: _onSelectionChanged,
                    ),
                  ],
                ),
              ),
              // Selection count
              if (_selectedCampaigns.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${_selectedCampaigns.length} source(s) selected'
                    '${_gameModeName.isNotEmpty ? ' [$_gameModeName]' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              // Action buttons
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: (_loading || _selectedCampaigns.isEmpty)
                        ? null
                        : _handleLoad,
                    child: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Load'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Basic tab: grouped presets by game mode
// ---------------------------------------------------------------------------

class _BasicPresetsPanel extends StatefulWidget {
  final void Function(List<Campaign>, String) onSelected;
  const _BasicPresetsPanel({required this.onSelected});

  @override
  State<_BasicPresetsPanel> createState() => _BasicPresetsPanelState();
}

class _BasicPresetsPanelState extends State<_BasicPresetsPanel> {
  // Groups of game mode → list of (label, campaign-name keywords)
  late final Map<String, List<_Preset>> _presets;
  String? _selectedPresetId;

  @override
  void initState() {
    super.initState();
    _presets = _buildPresets();
  }

  Map<String, List<_Preset>> _buildPresets() {
    // Build presets from the loaded campaign list.
    final gameModeKey = ListKey.getConstant<String>('GAMEMODES');
    final byMode = <String, List<Campaign>>{};
    for (final c in Globals.getCampaignList()) {
      final modes = c.getSafeListFor<String>(gameModeKey);
      final mode = modes.isNotEmpty ? modes.first : '(Unknown)';
      byMode.putIfAbsent(mode, () => []).add(c);
    }

    // For each game mode, show up to 6 highlighted campaigns as presets.
    // If a campaign's name contains "SRD" or "Core" we bump it to the top.
    final result = <String, List<_Preset>>{};
    for (final entry in byMode.entries) {
      final mode = entry.key;
      final sorted = [...entry.value]..sort((a, b) {
          final aScore = _importanceScore(a.getDisplayName());
          final bScore = _importanceScore(b.getDisplayName());
          return bScore.compareTo(aScore);
        });
      final presets = sorted.take(6).map((c) =>
          _Preset(c.getDisplayName(), [c], mode)).toList();
      if (presets.isNotEmpty) result[mode] = presets;
    }
    return result;
  }

  int _importanceScore(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('srd') || lower.contains('system reference')) return 3;
    if (lower.contains('core') || lower.contains('rulebook')) return 2;
    if (lower.contains('complete') || lower.contains('players')) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_presets.isEmpty) {
      return const Center(child: Text('No campaigns found. Use the Advanced tab.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Load — select a source set to load:',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          for (final entry in _presets.entries) ...[
            Text(entry.key,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: entry.value.map((preset) {
                final selected = _selectedPresetId == preset.id;
                return FilterChip(
                  selected: selected,
                  label: Text(preset.label,
                      style: const TextStyle(fontSize: 12)),
                  onSelected: (v) {
                    setState(() => _selectedPresetId = v ? preset.id : null);
                    if (v) {
                      widget.onSelected(preset.campaigns, preset.gameMode);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _Preset {
  final String label;
  final List<Campaign> campaigns;
  final String gameMode;
  String get id => '$gameMode:$label';
  const _Preset(this.label, this.campaigns, this.gameMode);
}
