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
