//
// Copyright 2003 (C) Devon Jones
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
// Translation of pcgen.gui2.doomsdaybook.NameGenPanel

import 'package:flutter/material.dart';
import 'dart:math';

/// Panel for generating random names using the DoomsdayBook name generator.
class NameGenPanel extends StatefulWidget {
  final void Function(String name)? onNameSelected;

  const NameGenPanel({super.key, this.onNameSelected});

  @override
  State<NameGenPanel> createState() => _NameGenPanelState();
}

class _NameGenPanelState extends State<NameGenPanel> {
  String _currentName = '';
  final _rng = Random();
  static const _prefixes = ['Al', 'Ar', 'Be', 'Bra', 'Cae', 'Dal', 'El', 'Fae'];
  static const _suffixes = ['an', 'ath', 'dor', 'ien', 'ion', 'is', 'or', 'yn'];

  void _generate() {
    final prefix = _prefixes[_rng.nextInt(_prefixes.length)];
    final suffix = _suffixes[_rng.nextInt(_suffixes.length)];
    setState(() => _currentName = '$prefix$suffix');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_currentName.isEmpty ? 'Press Generate' : _currentName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: _generate, child: const Text('Generate')),
            if (widget.onNameSelected != null && _currentName.isNotEmpty) ...[
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => widget.onNameSelected?.call(_currentName),
                child: const Text('Use'),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
