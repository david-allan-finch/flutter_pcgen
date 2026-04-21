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
