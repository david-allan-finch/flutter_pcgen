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
// Translation of pcgen.gui2.doomsdaybook.NameButton

import 'package:flutter/material.dart';

/// A button that generates and displays a random name.
class NameButton extends StatefulWidget {
  final String label;
  final void Function(String name)? onGenerated;

  const NameButton({super.key, this.label = 'Name', this.onGenerated});

  @override
  State<NameButton> createState() => _NameButtonState();
}

class _NameButtonState extends State<NameButton> {
  String? _generatedName;

  void _generate() {
    // Simple placeholder — real implementation reads from DoomsdayBook xml data
    setState(() => _generatedName = 'Generated Name');
    widget.onGenerated?.call(_generatedName!);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _generate,
      child: Text(_generatedName ?? widget.label),
    );
  }
}
