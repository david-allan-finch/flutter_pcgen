//
// Copyright (c) 2009 Tom Parker <thpr@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.gui2.converter.UnstretchingGridLayout

import 'package:flutter/material.dart';

/// A grid layout that does not stretch its children to fill available space.
/// Translates UnstretchingGridLayout (a custom Swing LayoutManager) to Flutter.
class UnstretchingGridLayout extends StatelessWidget {
  final int columns;
  final List<Widget> children;
  final double hGap;
  final double vGap;

  const UnstretchingGridLayout({
    super.key,
    required this.columns,
    required this.children,
    this.hGap = 4,
    this.vGap = 4,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final rowChildren = <Widget>[];
      for (var j = i; j < i + columns && j < children.length; j++) {
        if (rowChildren.isNotEmpty) rowChildren.add(SizedBox(width: hGap));
        rowChildren.add(children[j]);
      }
      if (rows.isNotEmpty) rows.add(SizedBox(height: vGap));
      rows.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: rowChildren,
      ));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
}
