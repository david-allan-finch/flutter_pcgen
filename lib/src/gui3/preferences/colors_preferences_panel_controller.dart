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
// Translation of pcgen.gui3.preferences.ColorsPreferencesPanelController

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/gui3/utilty/color_utilty.dart';

/// Controller/widget for the Colors preferences panel.
class ColorsPreferencesPanelController extends StatefulWidget {
  const ColorsPreferencesPanelController({super.key});

  @override
  State<ColorsPreferencesPanelController> createState() =>
      _ColorsPreferencesPanelControllerState();
}

class _ColorsPreferencesPanelControllerState
    extends State<ColorsPreferencesPanelController> {
  Color _qualifiedColor = Colors.black;
  Color _notQualifiedColor = Colors.grey;
  Color _automaticColor = Colors.blue;
  Color _virtualColor = const Color(0xFF006400); // dark green

  Widget _colorRow(String label, Color current, ValueChanged<Color> onChanged) {
    return ListTile(
      title: Text(label),
      trailing: InkWell(
        onTap: () async {
          // In a real implementation, show a color picker dialog.
          // For now, cycle through a few preset colors.
          final presets = [Colors.black, Colors.grey, Colors.blue, Colors.red];
          final next = presets[(presets.indexOf(current) + 1) % presets.length];
          onChanged(next);
        },
        child: Container(
          width: 40,
          height: 24,
          decoration: BoxDecoration(
            color: current,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            ColorUtilty.toHex(current),
            style: TextStyle(
              color: ColorUtilty.contrastColor(current),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _colorRow('Qualified Items', _qualifiedColor,
            (c) => setState(() => _qualifiedColor = c)),
        _colorRow('Not Qualified Items', _notQualifiedColor,
            (c) => setState(() => _notQualifiedColor = c)),
        _colorRow('Automatic Items', _automaticColor,
            (c) => setState(() => _automaticColor = c)),
        _colorRow('Virtual Items', _virtualColor,
            (c) => setState(() => _virtualColor = c)),
      ],
    );
  }
}
