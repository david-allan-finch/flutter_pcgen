//
// Copyright 2009 Connor Petty <cpmeister@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// Translation of pcgen.gui2.sources.AdvancedSourceSelectionPanel

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'package:flutter_pcgen/src/core/campaign.dart';
import 'package:flutter_pcgen/src/core/globals.dart';

/// Advanced panel showing all discovered campaigns grouped by game mode,
/// with search filtering and checkbox selection.
class AdvancedSourceSelectionPanel extends StatefulWidget {
  /// Called whenever the selection changes.
  /// [gameModeName] is the game mode of the first selected campaign, or ''.
  final void Function(List<Campaign> campaigns, String gameModeName)
      onSelectionChanged;

  const AdvancedSourceSelectionPanel({
    super.key,
    required this.onSelectionChanged,
  });

  @override
  State<AdvancedSourceSelectionPanel> createState() =>
      _AdvancedSourceSelectionPanelState();
}

class _AdvancedSourceSelectionPanelState
    extends State<AdvancedSourceSelectionPanel> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedKeys = {};

  // Campaigns grouped by their first GAMEMODE entry.
  late Map<String, List<Campaign>> _byGameMode;
  // Game modes sorted for display.
  late List<String> _sortedGameModes;
  // Which game mode nodes are expanded in the tree.
  final Set<String> _expandedModes = {};

  @override
  void initState() {
    super.initState();
    _buildIndex();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _buildIndex() {
    final gameModeKey = ListKey.getConstant<String>('GAMEMODES');
    _byGameMode = {};
    for (final c in Globals.getCampaignList()) {
      final modes = c.getSafeListFor<String>(gameModeKey);
      final mode = modes.isNotEmpty ? modes.first : '(Unknown)';
      _byGameMode.putIfAbsent(mode, () => []).add(c);
    }
    _sortedGameModes = _byGameMode.keys.toList()..sort();
    // Expand all modes by default if there are few enough.
    if (_sortedGameModes.length <= 5) {
      _expandedModes.addAll(_sortedGameModes);
    }
  }

  List<Campaign> _filtered(List<Campaign> campaigns) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return campaigns;
    return campaigns
        .where((c) => c.getDisplayName().toLowerCase().contains(query))
        .toList();
  }

  void _toggleCampaign(Campaign c, bool selected) {
    setState(() {
      if (selected) {
        _selectedKeys.add(c.getKeyName());
      } else {
        _selectedKeys.remove(c.getKeyName());
      }
    });
    _notifyParent();
  }

  void _toggleGameMode(String mode, bool selectAll) {
    final campaigns = _byGameMode[mode] ?? [];
    setState(() {
      if (selectAll) {
        for (final c in campaigns) _selectedKeys.add(c.getKeyName());
      } else {
        for (final c in campaigns) _selectedKeys.remove(c.getKeyName());
      }
    });
    _notifyParent();
  }

  void _notifyParent() {
    final selected = Globals.getCampaignList()
        .where((c) => _selectedKeys.contains(c.getKeyName()))
        .toList();

    String gameModeName = '';
    if (selected.isNotEmpty) {
      final gameModeKey = ListKey.getConstant<String>('GAMEMODES');
      final modes = selected.first.getSafeListFor<String>(gameModeKey);
      gameModeName = modes.isNotEmpty ? modes.first : '';
    }

    widget.onSelectionChanged(selected, gameModeName);
  }

  @override
  Widget build(BuildContext context) {
    final total = Globals.getCampaignList().length;

    if (total == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No sources found.\n\nMake sure the data/ directory is present next to the application.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Filter sources...',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Text(
            '$total source(s) available — ${_selectedKeys.length} selected',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _sortedGameModes.length,
            itemBuilder: (context, index) {
              final mode = _sortedGameModes[index];
              final campaigns = _filtered(_byGameMode[mode] ?? []);
              if (campaigns.isEmpty) return const SizedBox.shrink();
              return _GameModeSection(
                gameMode: mode,
                campaigns: campaigns,
                selectedKeys: _selectedKeys,
                expanded: _expandedModes.contains(mode),
                onExpandToggle: () => setState(() {
                  if (_expandedModes.contains(mode)) {
                    _expandedModes.remove(mode);
                  } else {
                    _expandedModes.add(mode);
                  }
                }),
                onToggleCampaign: _toggleCampaign,
                onToggleAll: _toggleGameMode,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Game mode section widget
// ---------------------------------------------------------------------------

class _GameModeSection extends StatelessWidget {
  final String gameMode;
  final List<Campaign> campaigns;
  final Set<String> selectedKeys;
  final bool expanded;
  final VoidCallback onExpandToggle;
  final void Function(Campaign, bool) onToggleCampaign;
  final void Function(String, bool) onToggleAll;

  const _GameModeSection({
    required this.gameMode,
    required this.campaigns,
    required this.selectedKeys,
    required this.expanded,
    required this.onExpandToggle,
    required this.onToggleCampaign,
    required this.onToggleAll,
  });

  @override
  Widget build(BuildContext context) {
    final selectedCount =
        campaigns.where((c) => selectedKeys.contains(c.getKeyName())).length;
    final allSelected = selectedCount == campaigns.length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          InkWell(
            onTap: onExpandToggle,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      gameMode,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Text(
                    '$selectedCount / ${campaigns.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => onToggleAll(gameMode, !allSelected),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(60, 28),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(allSelected ? 'None' : 'All'),
                  ),
                ],
              ),
            ),
          ),
          // Campaign list
          if (expanded)
            ...campaigns.map((c) => _CampaignRow(
                  campaign: c,
                  selected: selectedKeys.contains(c.getKeyName()),
                  onToggle: (v) => onToggleCampaign(c, v),
                )),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual campaign row
// ---------------------------------------------------------------------------

class _CampaignRow extends StatelessWidget {
  final Campaign campaign;
  final bool selected;
  final ValueChanged<bool> onToggle;

  const _CampaignRow({
    required this.campaign,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final pubShort = campaign.getString(StringKey.pubNameShort) ?? '';
    final subtitle = pubShort.isNotEmpty ? pubShort : null;

    return CheckboxListTile(
      dense: true,
      value: selected,
      onChanged: (v) => onToggle(v ?? false),
      title: Text(
        campaign.getDisplayName(),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.only(left: 24, right: 8),
    );
  }
}
