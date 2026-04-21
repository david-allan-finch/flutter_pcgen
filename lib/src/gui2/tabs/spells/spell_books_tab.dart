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
// Translation of pcgen.gui2.tabs.spells.SpellBooksTab

import 'package:flutter/material.dart';
import 'spell_tree_view_model.dart';

/// Tab for managing spell books and the spells recorded in them.
class SpellBooksTab extends StatefulWidget {
  final dynamic character;

  const SpellBooksTab({super.key, this.character});

  @override
  State<SpellBooksTab> createState() => _SpellBooksTabState();
}

class _SpellBook {
  String name;
  final List<Map<String, dynamic>> spells;
  _SpellBook({required this.name, List<Map<String, dynamic>>? spells})
      : spells = spells ?? [];
}

class _SpellBooksTabState extends State<SpellBooksTab> {
  final List<_SpellBook> _books = [
    _SpellBook(name: 'Spell Book'),
  ];
  int _selectedBook = 0;
  String _selectedView = SpellTreeViewModel.levelView;

  void _addBook() {
    setState(() => _books.add(_SpellBook(name: 'New Book ${_books.length + 1}')));
  }

  void _removeBook(int index) {
    if (_books.length <= 1) return;
    setState(() {
      _books.removeAt(index);
      if (_selectedBook >= _books.length) _selectedBook = _books.length - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final book = _books[_selectedBook];
    final byLevel = <int, List<Map<String, dynamic>>>{};
    for (final s in book.spells) {
      byLevel.putIfAbsent((s['level'] as int?) ?? 0, () => []).add(s);
    }

    return Row(
      children: [
        SizedBox(
          width: 180,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _books.length,
                  itemBuilder: (ctx, i) => ListTile(
                    selected: i == _selectedBook,
                    title: Text(_books[i].name),
                    onTap: () => setState(() => _selectedBook = i),
                    trailing: _books.length > 1
                        ? IconButton(
                            icon: const Icon(Icons.delete, size: 16),
                            onPressed: () => _removeBook(i),
                          )
                        : null,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Book'),
                  onPressed: _addBook,
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(),
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Text(book.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    const Text('View by: '),
                    DropdownButton<String>(
                      value: _selectedView,
                      items: [SpellTreeViewModel.levelView, SpellTreeViewModel.schoolView]
                          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedView = v);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: book.spells.isEmpty
                    ? const Center(child: Text('No spells in this book'))
                    : ListView(
                        children: byLevel.entries.map((entry) {
                          return ExpansionTile(
                            title: Text('Level ${entry.key}',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            children: entry.value
                                .map((s) => ListTile(
                                      title: Text(s['name'] as String? ?? ''),
                                      subtitle: Text(s['school'] as String? ?? ''),
                                    ))
                                .toList(),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
