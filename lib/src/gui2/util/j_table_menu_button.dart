//
// Copyright 2016 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.util.JTableMenuButton

import 'package:flutter/material.dart';

/// A small drop-down arrow button displayed in the upper-right corner of a
/// [JDynamicTable] or [JTreeViewTable] that opens a [PopupMenuButton].
class JTableMenuButton extends StatelessWidget {
  final List<PopupMenuEntry<dynamic>> Function(BuildContext) itemBuilder;
  final void Function(dynamic)? onSelected;

  const JTableMenuButton({
    super.key,
    required this.itemBuilder,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: PopupMenuButton<dynamic>(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.arrow_drop_down, size: 14),
        itemBuilder: itemBuilder,
        onSelected: onSelected,
      ),
    );
  }
}
