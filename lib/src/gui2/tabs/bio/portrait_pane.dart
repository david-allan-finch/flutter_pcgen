//
// Copyright 2011 Connor Petty <cpmeister@users.sourceforge.net>
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
