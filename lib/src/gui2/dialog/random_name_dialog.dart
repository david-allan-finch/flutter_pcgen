//
// Copyright James Dempsey, 2010
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
// Translation of pcgen.gui2.dialog.RandomNameDialog

import 'package:flutter/material.dart';

/// Dialog for generating a random name for a character.
class RandomNameDialog extends StatefulWidget {
  final dynamic character;

  const RandomNameDialog({super.key, required this.character});

  @override
  State<RandomNameDialog> createState() => _RandomNameDialogState();
}

class _RandomNameDialogState extends State<RandomNameDialog> {
  String _generatedName = '';

  void _generateName() {
    setState(() => _generatedName = 'Random Name ${DateTime.now().millisecond}');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Random Name Generator'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_generatedName.isEmpty ? 'Press Generate' : _generatedName,
              style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: _generateName, child: const Text('Generate')),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _generatedName.isEmpty
              ? null
              : () => Navigator.pop(context, _generatedName),
          child: const Text('Use Name'),
        ),
      ],
    );
  }
}
