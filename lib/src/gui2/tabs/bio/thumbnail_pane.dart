// Translation of pcgen.gui2.tabs.bio.ThumbnailPane

import 'package:flutter/material.dart';

/// Displays a thumbnail crop of the character portrait.
class ThumbnailPane extends StatelessWidget {
  final String? imagePath;
  final Rect? cropRect;

  const ThumbnailPane({super.key, this.imagePath, this.cropRect});

  @override
  Widget build(BuildContext context) {
    if (imagePath == null) {
      return Container(
        width: 100,
        height: 130,
        color: Colors.grey.shade300,
        child: const Icon(Icons.person, size: 64, color: Colors.grey),
      );
    }
    return SizedBox(
      width: 100,
      height: 130,
      child: ClipRect(
        child: Image.asset(
          imagePath!,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
