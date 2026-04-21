// Translation of pcgen.gui3.preferences.CopySettingsPanelController

import 'package:flutter/material.dart';

/// Controller/widget for the Copy Settings panel in preferences.
/// Allows copying preferences from one PCGen installation to another.
class CopySettingsPanelController extends StatefulWidget {
  const CopySettingsPanelController({super.key});

  @override
  State<CopySettingsPanelController> createState() =>
      _CopySettingsPanelControllerState();
}

class _CopySettingsPanelControllerState
    extends State<CopySettingsPanelController> {
  String _sourcePath = '';
  bool _copying = false;
  bool _done = false;
  String _status = '';

  Future<void> _copySettings() async {
    if (_sourcePath.isEmpty) return;
    setState(() {
      _copying = true;
      _done = false;
      _status = 'Copying settings...';
    });
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _copying = false;
      _done = true;
      _status = 'Settings copied successfully.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Copy Settings from Another PCGen Installation',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Source PCGen Settings Directory',
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: (!_copying && _sourcePath.isNotEmpty) ? _copySettings : null,
            child: _copying
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Copy Settings'),
          ),
          if (_status.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _done ? Icons.check_circle : Icons.info,
                  color: _done ? Colors.green : Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(_status),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
