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
// Translation of pcgen.gui2.kits.KitPanel

import 'package:flutter/material.dart';

/// Panel for browsing and applying kits to a character.
class KitPanel extends StatefulWidget {
  final dynamic character;

  const KitPanel({super.key, required this.character});

  @override
  State<KitPanel> createState() => _KitPanelState();
}

class _KitPanelState extends State<KitPanel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text('Kits'),
          automaticallyImplyLeading: false,
        ),
        const Expanded(
          child: Center(child: Text('Available kits')),
        ),
      ],
    );
  }
}
