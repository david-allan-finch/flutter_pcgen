// Translation of pcgen.gui2.util.JTableMenuButton

import 'package:flutter/material.dart';

/// A small drop-down arrow button displayed in the upper-right corner of a
/// [JDynamicTable] or [JTreeViewTable] that opens a [PopupMenuButton].
class JTableMenuButton extends StatelessWidget {
  final List<PopupMenuEntry<dynamic>> Function(BuildContext) itemBuilder;
  final void Function(dynamic)? onSelected;

  const JTableMenuButton({
    super.key,
    required this.itemBuilder,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: PopupMenuButton<dynamic>(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.arrow_drop_down, size: 14),
        itemBuilder: itemBuilder,
        onSelected: onSelected,
      ),
    );
  }
}
