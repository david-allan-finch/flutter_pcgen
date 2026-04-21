// Translation of pcgen.gui3.component.PCGenToolBar

import 'package:flutter/material.dart';

/// PCGen main toolbar with icon buttons for common actions.
class PCGenToolBar extends StatelessWidget {
  final List<PCGenToolBarItem> items;

  const PCGenToolBar({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: items.map((item) {
          if (item.isSeparator) {
            return const VerticalDivider(width: 8);
          }
          return ValueListenableBuilder<bool>(
            valueListenable: item.enabled,
            builder: (ctx, enabled, _) => Tooltip(
              message: item.tooltip ?? item.label ?? '',
              child: IconButton(
                icon: Icon(item.icon),
                onPressed: enabled ? item.onPressed : null,
                iconSize: 20,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class PCGenToolBarItem {
  final IconData icon;
  final String? label;
  final String? tooltip;
  final VoidCallback? onPressed;
  final ValueNotifier<bool> enabled;
  final bool isSeparator;

  PCGenToolBarItem({
    required this.icon,
    this.label,
    this.tooltip,
    this.onPressed,
    ValueNotifier<bool>? enabled,
  })  : enabled = enabled ?? ValueNotifier(true),
        isSeparator = false;

  const PCGenToolBarItem.separator()
      : icon = Icons.more_vert,
        label = null,
        tooltip = null,
        onPressed = null,
        enabled = const _AlwaysTrueNotifier(),
        isSeparator = true;
}

class _AlwaysTrueNotifier extends ValueNotifier<bool> {
  const _AlwaysTrueNotifier() : super(true);
}
