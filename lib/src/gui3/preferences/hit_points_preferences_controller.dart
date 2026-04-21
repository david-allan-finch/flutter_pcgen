// Translation of pcgen.gui3.preferences.HitPointsPreferencesController

import 'package:flutter/material.dart';

/// Controller/widget for the Hit Points section of preferences.
class HitPointsPreferencesController extends StatefulWidget {
  final int initialHPMethod;
  final ValueChanged<int>? onChanged;

  const HitPointsPreferencesController({
    super.key,
    this.initialHPMethod = 0,
    this.onChanged,
  });

  @override
  State<HitPointsPreferencesController> createState() =>
      _HitPointsPreferencesControllerState();
}

class _HitPointsPreferencesControllerState
    extends State<HitPointsPreferencesController> {
  static const List<String> _methods = [
    'Standard (Roll)',
    'Auto Max',
    'Percentage',
    'Average',
  ];

  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialHPMethod;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text('Hit Points Method',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ..._methods.asMap().entries.map((e) => RadioListTile<int>(
              value: e.key,
              groupValue: _selected,
              title: Text(e.value),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _selected = v);
                  widget.onChanged?.call(v);
                }
              },
            )),
      ],
    );
  }
}
