// Translation of pcgen.gui2.tabs.bio.PortraitPane

import 'package:flutter/material.dart';

/// Displays the full character portrait with crop controls.
class PortraitPane extends StatefulWidget {
  final String? imagePath;
  final ValueChanged<String?>? onImageChanged;

  const PortraitPane({super.key, this.imagePath, this.onImageChanged});

  @override
  State<PortraitPane> createState() => _PortraitPaneState();
}

class _PortraitPaneState extends State<PortraitPane> {
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.imagePath;
  }

  void _clearPortrait() {
    setState(() => _imagePath = null);
    widget.onImageChanged?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 200,
          height: 260,
          color: Colors.grey.shade200,
          child: _imagePath == null
              ? const Center(child: Icon(Icons.person, size: 96, color: Colors.grey))
              : Image.asset(_imagePath!, fit: BoxFit.contain),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                // File picker would go here
              },
              child: const Text('Choose Portrait'),
            ),
            const SizedBox(width: 8),
            if (_imagePath != null)
              OutlinedButton(
                onPressed: _clearPortrait,
                child: const Text('Clear'),
              ),
          ],
        ),
      ],
    );
  }
}
