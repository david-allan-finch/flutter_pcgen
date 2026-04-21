//
// Copyright 2011 Connor Petty <cpmeister@users.sourceforge.net>
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
