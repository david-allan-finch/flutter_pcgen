//
// Copyright 2009 Connor Petty <cpmeister@users.sourceforge.net>
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
