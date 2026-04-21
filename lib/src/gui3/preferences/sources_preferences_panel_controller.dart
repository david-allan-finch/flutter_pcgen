//
// Copyright 2019 (C) Eitan Adler <lists@eitanadler.com>
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
// Translation of pcgen.gui3.preferences.SourcesPreferencesPanelController

import 'package:flutter/material.dart';

/// Controller/widget for the Sources preferences panel.
class SourcesPreferencesPanelController extends StatefulWidget {
  const SourcesPreferencesPanelController({super.key});

  @override
  State<SourcesPreferencesPanelController> createState() =>
      _SourcesPreferencesPanelControllerState();
}

class _SourcesPreferencesPanelControllerState
    extends State<SourcesPreferencesPanelController> {
  bool _loadLastSources = true;
  bool _allowMultipleSources = true;
  bool _saveSourcesWithChar = false;
  String _pccDirectory = '';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          title: const Text('Load Last Sources on Startup'),
          value: _loadLastSources,
          onChanged: (v) => setState(() => _loadLastSources = v),
        ),
        SwitchListTile(
          title: const Text('Allow Multiple Source Types'),
          value: _allowMultipleSources,
          onChanged: (v) => setState(() => _allowMultipleSources = v),
        ),
        SwitchListTile(
          title: const Text('Save Sources with Character'),
          value: _saveSourcesWithChar,
          onChanged: (v) => setState(() => _saveSourcesWithChar = v),
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text('PCC Directory',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: _pccDirectory),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) => _pccDirectory = v,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // File picker would go here
                },
                child: const Text('Browse...'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
