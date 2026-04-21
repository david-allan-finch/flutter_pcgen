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
