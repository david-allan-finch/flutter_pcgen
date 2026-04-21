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
// Translation of pcgen.gui2.prefs.OutputPanel

import 'package:flutter/material.dart';

/// Preferences panel for output/export settings.
class OutputPanel extends StatefulWidget {
  const OutputPanel({super.key});

  @override
  State<OutputPanel> createState() => _OutputPanelState();
}

class _OutputPanelState extends State<OutputPanel> {
  bool _alwaysOpenExport = false;
  bool _saveWithPc = true;
  bool _cleanupTempFiles = true;
  String _defaultHtmlSheet = '';
  String _defaultPdfSheet = '';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Output', style: Theme.of(context).textTheme.titleMedium),
        const Divider(),
        TextField(
          decoration: const InputDecoration(labelText: 'Default HTML Output Sheet'),
          onChanged: (v) => _defaultHtmlSheet = v,
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(labelText: 'Default PDF Output Sheet'),
          onChanged: (v) => _defaultPdfSheet = v,
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: const Text('Always open export file after export'),
          value: _alwaysOpenExport,
          onChanged: (v) => setState(() => _alwaysOpenExport = v ?? false),
        ),
        CheckboxListTile(
          title: const Text('Save output sheet with PC'),
          value: _saveWithPc,
          onChanged: (v) => setState(() => _saveWithPc = v ?? true),
        ),
        CheckboxListTile(
          title: const Text('Cleanup temp files on exit'),
          value: _cleanupTempFiles,
          onChanged: (v) => setState(() => _cleanupTempFiles = v ?? true),
        ),
      ],
    );
  }
}
