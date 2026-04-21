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
// Translation of pcgen.gui2.converter.PCGenDataConvert

import 'package:flutter/material.dart';
import 'convert_panel.dart';

/// Entry point for the LST data conversion tool.
/// Shows the ConvertPanel in a dialog window.
class PCGenDataConvert {
  PCGenDataConvert._();

  static Future<void> show(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        child: SizedBox(
          width: 700,
          height: 500,
          child: Scaffold(
            appBar: AppBar(title: const Text('PCGen Data Converter')),
            body: const ConvertPanel(),
          ),
        ),
      ),
    );
  }
}
