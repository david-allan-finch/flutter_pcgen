// Translation of pcgen.gui2.converter.panel.SourceSelectionPanel

import 'package:flutter/material.dart';
import 'convert_sub_panel.dart';

/// Wizard step: select the source directory containing the LST files to convert.
class SourceSelectionPanel extends ConvertSubPanel {
  const SourceSelectionPanel({super.key});

  @override
  bool get isComplete => true;

  @override
  State<SourceSelectionPanel> createState() => _SourceSelectionPanelState();
}

class _SourceSelectionPanelState extends ConvertSubPanelState<SourceSelectionPanel> {
  String _sourcePath = '';
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
          const Text('Select Source Directory',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Select the directory containing the LST files to convert:'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Source Directory',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _sourcePath = v),
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
          if (_sourcePath.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Selected: $_sourcePath',
                style: const TextStyle(color: Colors.green)),
          ],
        ],
      ),
    );
  }
}
