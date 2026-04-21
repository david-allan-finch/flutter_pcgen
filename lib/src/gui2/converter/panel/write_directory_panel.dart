//
// Copyright (c) 2009 Tom Parker <thpr@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.gui2.converter.panel.WriteDirectoryPanel

import 'package:flutter/material.dart';
import 'convert_sub_panel.dart';

/// Wizard step: select the output directory for converted LST files.
class WriteDirectoryPanel extends ConvertSubPanel {
  const WriteDirectoryPanel({super.key});

  @override
  bool get isComplete => true;

  @override
  State<WriteDirectoryPanel> createState() => _WriteDirectoryPanelState();
}

class _WriteDirectoryPanelState extends ConvertSubPanelState<WriteDirectoryPanel> {
  String _outputPath = '';
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Output Directory',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Select where the converted files will be written:'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Output Directory',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _outputPath = v),
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
          if (_outputPath.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Output: $_outputPath',
                style: const TextStyle(color: Colors.green)),
          ],
          const SizedBox(height: 16),
          const Card(
            color: Color(0xFFFFF9C4),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Warning: existing files in the output directory may be overwritten.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
