// Translation of pcgen.gui2.sources.AdvancedSourceSelectionPanel

import 'package:flutter/material.dart';

/// Advanced panel for selecting sources with per-source checkboxes and filtering.
class AdvancedSourceSelectionPanel extends StatefulWidget {
  const AdvancedSourceSelectionPanel({super.key});

  @override
  State<AdvancedSourceSelectionPanel> createState() =>
      _AdvancedSourceSelectionPanelState();
}

class _AdvancedSourceSelectionPanelState
    extends State<AdvancedSourceSelectionPanel> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selected = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Filter sources...',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const Expanded(
          child: Center(child: Text('Available sources will appear here')),
        ),
      ],
    );
  }
}
