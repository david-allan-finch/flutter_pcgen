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
// Translation of pcgen.gui2.tabs.bio.NoteInfoPane

import 'package:flutter/material.dart';

/// Panel for free-form character notes.
class NoteInfoPane extends StatefulWidget {
  final dynamic character;

  const NoteInfoPane({super.key, this.character});

  @override
  State<NoteInfoPane> createState() => _NoteInfoPaneState();
}

class _NoteInfoPaneState extends State<NoteInfoPane> {
  final List<_NoteEntry> _notes = [];
  int? _selectedIndex;

  void _addNote() {
    setState(() {
      _notes.add(_NoteEntry(name: 'New Note ${_notes.length + 1}', content: ''));
      _selectedIndex = _notes.length - 1;
    });
  }

  void _removeNote() {
    if (_selectedIndex == null) return;
    setState(() {
      _notes.removeAt(_selectedIndex!);
      _selectedIndex = _notes.isEmpty ? null : (_selectedIndex! - 1).clamp(0, _notes.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _notes.length,
                  itemBuilder: (ctx, i) => ListTile(
                    selected: i == _selectedIndex,
                    title: Text(_notes[i].name),
                    onTap: () => setState(() => _selectedIndex = i),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(icon: const Icon(Icons.add), onPressed: _addNote),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _selectedIndex != null ? _removeNote : null,
                  ),
                ],
              ),
            ],
          ),
        ),
        const VerticalDivider(),
        Expanded(
          child: _selectedIndex == null
              ? const Center(child: Text('Select or add a note'))
              : _NoteEditor(
                  key: ValueKey(_selectedIndex),
                  note: _notes[_selectedIndex!],
                  onNameChanged: (v) => setState(() => _notes[_selectedIndex!].name = v),
                  onContentChanged: (v) => _notes[_selectedIndex!].content = v,
                ),
        ),
      ],
    );
  }
}

class _NoteEntry {
  String name;
  String content;
  _NoteEntry({required this.name, required this.content});
}

class _NoteEditor extends StatelessWidget {
  final _NoteEntry note;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onContentChanged;

  const _NoteEditor({
    super.key,
    required this.note,
    required this.onNameChanged,
    required this.onContentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          TextField(
            controller: TextEditingController(text: note.name),
            decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
            onChanged: onNameChanged,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: note.content),
              expands: true,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              onChanged: onContentChanged,
            ),
          ),
        ],
      ),
    );
  }
}
