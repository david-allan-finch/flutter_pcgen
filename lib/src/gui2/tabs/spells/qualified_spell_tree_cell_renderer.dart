//
// Copyright James Dempsey, 2012
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
// Translation of pcgen.gui2.tabs.spells.QualifiedSpellTreeCellRenderer

import 'package:flutter/material.dart';

/// Tree cell renderer for spells that shows qualification status via color.
class QualifiedSpellTreeCellRenderer extends StatelessWidget {
  final dynamic item;
  final bool isSelected;
  final bool isExpanded;
  final bool hasChildren;

  const QualifiedSpellTreeCellRenderer({
    super.key,
    required this.item,
    this.isSelected = false,
    this.isExpanded = false,
    this.hasChildren = false,
  });

  @override
  Widget build(BuildContext context) {
    final label = _label();
    final style = _style(context);

    return Container(
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: Row(
        children: [
          if (hasChildren)
            Icon(isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                size: 16, color: Colors.grey)
          else
            const SizedBox(width: 16),
          Text(label, style: style),
        ],
      ),
    );
  }

  String _label() {
    if (item is Map) return item['name'] as String? ?? '';
    return item?.toString() ?? '';
  }

  TextStyle _style(BuildContext context) {
    if (item is Map) {
      final prohibited = item['prohibited'] as bool? ?? false;
      if (prohibited) {
        return const TextStyle(color: Colors.red, fontSize: 13);
      }
      final qualified = item['qualified'] as bool? ?? true;
      if (!qualified) {
        return const TextStyle(color: Colors.grey, fontSize: 13);
      }
    }
    return const TextStyle(fontSize: 13);
  }
}
