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
