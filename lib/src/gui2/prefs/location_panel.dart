//
// Copyright 2010(C) James Dempsey
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
// Translation of pcgen.gui2.prefs.LocationPanel

import 'package:flutter/material.dart';

/// Preferences panel for file location settings (data, output, backup dirs).
class LocationPanel extends StatefulWidget {
  const LocationPanel({super.key});

  @override
  State<LocationPanel> createState() => _LocationPanelState();
}

class _LocationPanelState extends State<LocationPanel> {
  final Map<String, TextEditingController> _controllers = {
    'Data Directory': TextEditingController(),
    'Output Directory': TextEditingController(),
    'Backup Directory': TextEditingController(),
    'Character Directory': TextEditingController(),
  };

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('File Locations', style: Theme.of(context).textTheme.titleMedium),
        const Divider(),
        ..._controllers.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: entry.value,
                      decoration: InputDecoration(labelText: entry.key),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: () {/* file picker */},
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
