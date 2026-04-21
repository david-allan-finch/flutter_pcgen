//
// Copyright 2011 Connor Petty <cpmeister@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.gui2.InfoGuidePane

import 'package:flutter/material.dart';
import 'ui_context.dart';
import 'package:flutter_pcgen/src/facade/core/source_selection_facade.dart';

/// Provides a guide for first-time users showing what to do next
/// and which sources are loaded.
class InfoGuidePane extends StatefulWidget {
  final dynamic frame; // PCGenFrame
  final UIContext uiContext;

  const InfoGuidePane({super.key, required this.frame, required this.uiContext});

  @override
  State<InfoGuidePane> createState() => _InfoGuidePaneState();
}

class _InfoGuidePaneState extends State<InfoGuidePane> {
  SourceSelectionFacade? _currentSources;
  bool _visible = true;
  String _currentTip = '';

  @override
  void initState() {
    super.initState();
    _currentTip = _getNextTip();
    widget.uiContext.getCurrentSourceSelectionRef().addListener(_onSourcesChanged);
  }

  @override
  void dispose() {
    widget.uiContext.getCurrentSourceSelectionRef().removeListener(_onSourcesChanged);
    super.dispose();
  }

  void _onSourcesChanged() {
    setState(() {
      _currentSources = widget.uiContext.getCurrentSourceSelectionRef().get();
    });
  }

  String _getNextTip() {
    return 'Load a source book to get started.';
  }

  String _getGameModeHtml() {
    if (_currentSources == null) return '(none selected)';
    return _currentSources!.getGameMode().get()?.getDisplayName() ?? '(none selected)';
  }

  String _getCampaignsHtml() {
    if (_currentSources == null || _currentSources!.getCampaigns().isEmpty) {
      return '(no sources loaded)';
    }
    final sb = StringBuffer();
    for (final campaign in _currentSources!.getCampaigns()) {
      sb.writeln('• ${campaign.getKeyName()}');
    }
    return sb.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return Center(
      child: Container(
        width: 650,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to PCGen',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const Text('Current Game Mode:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_getGameModeHtml()),
            const SizedBox(height: 8),
            const Text('Loaded Sources:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_getCampaignsHtml()),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.blue.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What to do next:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Text(
                    '1. Load sources via Sources > Load Sources...\n'
                    '2. Create a new character via File > New\n'
                    '3. Open an existing character via File > Open',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.yellow.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tip of the Day:',
                      style: Theme.of(context).textTheme.titleSmall),
                  Text(_currentTip),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
