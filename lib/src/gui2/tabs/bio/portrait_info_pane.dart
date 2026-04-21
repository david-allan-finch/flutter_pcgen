// Translation of pcgen.gui2.tabs.bio.PortraitInfoPane

import 'package:flutter/material.dart';
import 'portrait_pane.dart';
import 'thumbnail_pane.dart';

/// Panel combining the full portrait display and thumbnail crop preview.
class PortraitInfoPane extends StatefulWidget {
  final dynamic character;

  const PortraitInfoPane({super.key, this.character});

  @override
  State<PortraitInfoPane> createState() => _PortraitInfoPaneState();
}

class _PortraitInfoPaneState extends State<PortraitInfoPane> {
  String? _imagePath;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Portrait',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              PortraitPane(
                imagePath: _imagePath,
                onImageChanged: (p) => setState(() => _imagePath = p),
              ),
            ],
          ),
          const SizedBox(width: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Thumbnail',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              ThumbnailPane(imagePath: _imagePath),
              const SizedBox(height: 8),
              const Text('Used on the character sheet',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
