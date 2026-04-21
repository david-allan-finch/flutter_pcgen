//
// Copyright James Dempsey, 2013
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
// Translation of pcgen.gui2.equip.EquipQualifiedTreeCellRenderer

import 'package:flutter/material.dart';

/// Renders tree cells for equipment items, showing qualification status.
class EquipQualifiedTreeCellRenderer {
  final dynamic character;

  EquipQualifiedTreeCellRenderer(this.character);

  Widget buildCell(BuildContext context, dynamic item, bool isSelected) {
    final qualified = _isQualified(item);
    return Container(
      color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : null,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          Icon(
            qualified ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: qualified ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            item?.toString() ?? '',
            style: TextStyle(
              color: qualified ? null : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  bool _isQualified(dynamic item) {
    try {
      return item?.qualifies(character) as bool? ?? true;
    } catch (_) {
      return true;
    }
  }
}
