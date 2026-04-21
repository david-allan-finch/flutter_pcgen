//
// Copyright 2008 (C) James Dempsey
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
// Translation of pcgen.gui2.converter.panel.SummaryPanel

import 'package:flutter/material.dart';
import 'convert_sub_panel.dart';

/// Wizard step: final summary of what was converted.
class SummaryPanel extends ConvertSubPanel {
  final int filesConverted;
  final int warnings;
  final int errors;
  final String outputPath;

  const SummaryPanel({
    super.key,
    this.filesConverted = 0,
    this.warnings = 0,
    this.errors = 0,
    this.outputPath = '',
  });

  @override
  bool get isComplete => true;

  @override
  State<SummaryPanel> createState() => _SummaryPanelState();
}

class _SummaryPanelState extends ConvertSubPanelState<SummaryPanel> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Conversion Summary',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 24),
          _statRow(Icons.description, 'Files converted', widget.filesConverted),
          _statRow(Icons.warning_amber, 'Warnings', widget.warnings,
              color: widget.warnings > 0 ? Colors.orange : null),
          _statRow(Icons.error, 'Errors', widget.errors,
              color: widget.errors > 0 ? Colors.red : null),
          const SizedBox(height: 16),
          if (widget.outputPath.isNotEmpty) ...[
            const Text('Output written to:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(widget.outputPath),
          ],
          const SizedBox(height: 24),
          if (widget.errors == 0)
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 8),
                Text('Conversion completed successfully.',
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _statRow(IconData icon, String label, int value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.grey, size: 20),
          const SizedBox(width: 8),
          Text('$label: '),
          Text('$value',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }
}
