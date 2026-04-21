// Translation of pcgen.gui2.filter.FilterButton

import 'package:flutter/material.dart';
import 'displayable_filter.dart';

/// A toggle button that enables/disables a filter.
class FilterButton<T> extends StatefulWidget {
  final DisplayableFilter<T> filter;
  final bool initiallySelected;
  final void Function(DisplayableFilter<T> filter, bool selected)? onToggle;

  const FilterButton({
    super.key,
    required this.filter,
    this.initiallySelected = false,
    this.onToggle,
  });

  @override
  State<FilterButton<T>> createState() => _FilterButtonState<T>();
}

class _FilterButtonState<T> extends State<FilterButton<T>> {
  late bool _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initiallySelected;
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.filter.getDescription() ?? widget.filter.getDisplayName(),
      child: FilterChip(
        label: Text(widget.filter.getDisplayName()),
        selected: _selected,
        onSelected: (v) {
          setState(() => _selected = v);
          widget.onToggle?.call(widget.filter, v);
        },
      ),
    );
  }
}
