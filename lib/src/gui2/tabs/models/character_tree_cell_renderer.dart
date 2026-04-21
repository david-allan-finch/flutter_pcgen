//
// Copyright 2014 Connor
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
// Translation of pcgen.gui2.tabs.models.CharacterTreeCellRenderer

import 'package:flutter/material.dart';

/// Custom renderer for tree cells that shows qualified/restricted items
/// with visual indicators (icons, color) based on their status.
class CharacterTreeCellRenderer extends StatelessWidget {
  final dynamic item;
  final bool isSelected;
  final bool isExpanded;
  final bool hasChildren;

  const CharacterTreeCellRenderer({
    super.key,
    required this.item,
    this.isSelected = false,
    this.isExpanded = false,
    this.hasChildren = false,
  });

  @override
  Widget build(BuildContext context) {
    final label = _getLabel();
    final color = _getColor(context);
    final icon = hasChildren
        ? (isExpanded ? Icons.expand_more : Icons.chevron_right)
        : Icons.circle;

    return Container(
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 13)),
        ],
      ),
    );
  }

  String _getLabel() {
    if (item is Map) return item['name'] as String? ?? item.toString();
    return item?.toString() ?? '';
  }

  Color? _getColor(BuildContext context) {
    if (item is Map) {
      final qualified = item['qualified'] as bool? ?? true;
      if (!qualified) return Colors.grey;
    }
    return null;
  }
}
