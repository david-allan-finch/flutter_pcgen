//
// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
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
