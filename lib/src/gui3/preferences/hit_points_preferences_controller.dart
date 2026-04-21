//
// Copyright 2019 (C) Eitan Adler <lists@eitanadler.com>
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
