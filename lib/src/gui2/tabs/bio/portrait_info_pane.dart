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
// Translation of pcgen.gui2.tabs.bio.PortraitInfoPane

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/gui2/tabs/bio/portrait_pane.dart';
import 'package:flutter_pcgen/src/gui2/tabs/bio/thumbnail_pane.dart';

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
