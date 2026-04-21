//
// Copyright (c) 2009 Tom Parker <thpr@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.gui2.converter.panel.StartupPanel

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/gui2/converter/panel/convert_sub_panel.dart';

/// First wizard step: welcome/intro message for the converter.
class StartupPanel extends ConvertSubPanel {
  const StartupPanel({super.key});

  @override
  bool get isComplete => true;

  @override
  State<StartupPanel> createState() => _StartupPanelState();
}

class _StartupPanelState extends ConvertSubPanelState<StartupPanel> {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome to the PCGen Data Converter',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 16),
          Text(
            'This tool will help you convert LST data files from an older format '
            'to the current PCGen format.\n\n'
            'Click Next to begin.',
          ),
        ],
      ),
    );
  }
}
