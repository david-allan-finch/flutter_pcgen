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
