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
//
// Translation of pcgen.gui2.util.JListEx

import 'package:flutter/material.dart';

/// Callback type for double-click actions on a list item.
typedef ListDoubleClickCallback<E> = void Function(E item);

/// A ListView equivalent to JListEx that fires a callback on double-tap.
class JListEx<E> extends StatelessWidget {
  static const int actionDoubleclick = 2051;

  final List<E> items;
  final Widget Function(BuildContext, E) itemBuilder;
  final ListDoubleClickCallback<E>? onDoubleTap;
  final void Function(E)? onTap;

  const JListEx({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onDoubleTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (ctx, index) {
        final item = items[index];
        return GestureDetector(
          onDoubleTap: onDoubleTap == null ? null : () => onDoubleTap!(item),
          onTap: onTap == null ? null : () => onTap!(item),
          child: itemBuilder(ctx, item),
        );
      },
    );
  }
}
