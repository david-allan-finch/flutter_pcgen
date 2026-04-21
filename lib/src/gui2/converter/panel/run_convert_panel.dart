//
// Copyright 2009 (C) James Dempsey
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
// Translation of pcgen.gui2.converter.panel.RunConvertPanel

import 'package:flutter/material.dart';
import 'convert_sub_panel.dart';

/// Wizard step: shows progress while the conversion is running.
class RunConvertPanel extends ConvertSubPanel {
  const RunConvertPanel({super.key});

  @override
  bool get isComplete => true;

  @override
  State<RunConvertPanel> createState() => _RunConvertPanelState();
}

class _RunConvertPanelState extends ConvertSubPanelState<RunConvertPanel> {
  bool _running = false;
  bool _done = false;
  double _progress = 0;
  final List<String> _log = [];

  Future<void> _runConversion() async {
    setState(() {
      _running = true;
      _done = false;
      _progress = 0;
      _log.clear();
    });

    // Simulated conversion progress
    for (var i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        _progress = i / 10;
        _log.add('Processing step $i of 10...');
      });
    }

    setState(() {
      _running = false;
      _done = true;
      _log.add('Conversion complete.');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Run Conversion',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          if (!_running && !_done)
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Conversion'),
              onPressed: _runConversion,
            ),
          if (_running) ...[
            LinearProgressIndicator(value: _progress),
            const SizedBox(height: 8),
            Text('${(_progress * 100).toInt()}% complete'),
          ],
          if (_done)
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Conversion complete!',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _log.length,
                itemBuilder: (ctx, i) => Text(_log[i],
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
