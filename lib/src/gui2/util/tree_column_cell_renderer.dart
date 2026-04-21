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
