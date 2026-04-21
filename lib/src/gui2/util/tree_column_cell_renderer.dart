//
// Copyright 2016 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.util.TreeColumnCellRenderer

import 'package:flutter/material.dart';

/// A tree-cell renderer that ensures the tree-cell background matches the
/// enclosing table-cell background. Without this correction the tree cell
/// would render with its own default (usually white) background, creating
/// a visible mismatch.
class TreeColumnCellRenderer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final bool isSelected;
  final bool isExpanded;
  final bool isLeaf;

  const TreeColumnCellRenderer({
    super.key,
    required this.child,
    this.backgroundColor,
    this.isSelected = false,
    this.isExpanded = false,
    this.isLeaf = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Theme.of(context).colorScheme.surface;
    return Container(
      color: bg,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface,
        ),
        child: child,
      ),
    );
  }
}
