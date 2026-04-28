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
import 'package:flutter_pcgen/src/core/campaign.dart';
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
                    const Center(
                      child: Text(
                        'Quick-load presets coming soon.\nUse the Advanced tab to select sources.',
                        textAlign: TextAlign.center,
                      ),
                    ),
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
