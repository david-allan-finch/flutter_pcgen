// Translation of pcgen.gui2.tabs.equip.UnequippedList

import 'package:flutter/material.dart';

/// Widget listing all items currently not equipped to any slot.
class UnequippedList extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final ValueChanged<Map<String, dynamic>>? onEquip;

  const UnequippedList({super.key, required this.items, this.onEquip});

  @override
  State<UnequippedList> createState() => _UnequippedListState();
}

class _UnequippedListState extends State<UnequippedList> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Center(child: Text('No unequipped items'));
    }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: widget.items.length,
            itemBuilder: (ctx, i) {
              final item = widget.items[i];
              return ListTile(
                selected: i == _selectedIndex,
                title: Text(item['name'] as String? ?? ''),
                subtitle: Text(item['type'] as String? ?? ''),
                trailing: Text('x${item['qty'] ?? 1}'),
                onTap: () => setState(() => _selectedIndex = i),
                onLongPress: () {
                  if (widget.onEquip != null) widget.onEquip!(item);
                },
              );
            },
          ),
        ),
        if (_selectedIndex != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Equip Selected'),
              onPressed: () {
                if (_selectedIndex != null && widget.onEquip != null) {
                  widget.onEquip!(widget.items[_selectedIndex!]);
                }
              },
            ),
          ),
      ],
    );
  }
}
