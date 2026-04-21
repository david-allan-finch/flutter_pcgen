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
// Translation of pcgen.gui2.filter.FilterBar

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/gui2/filter/displayable_filter.dart';
import 'package:flutter_pcgen/src/gui2/filter/filter.dart';
import 'package:flutter_pcgen/src/gui2/filter/filter_button.dart';
import 'package:flutter_pcgen/src/gui2/filter/search_filter_panel.dart';

/// A bar containing a search field and filter toggle buttons.
class FilterBar<T> extends StatefulWidget {
  final List<DisplayableFilter<T>> filters;
  final void Function(Filter<T>? filter)? onFilterChanged;

  const FilterBar({
    super.key,
    this.filters = const [],
    this.onFilterChanged,
  });

  @override
  State<FilterBar<T>> createState() => _FilterBarState<T>();
}

class _FilterBarState<T> extends State<FilterBar<T>> {
  Filter<T>? _searchFilter;
  final Set<DisplayableFilter<T>> _activeFilters = {};

  void _updateFilter() {
    final filters = <Filter<T>>[];
    if (_searchFilter != null) filters.add(_searchFilter!);
    filters.addAll(_activeFilters);
    if (filters.isEmpty) {
      widget.onFilterChanged?.call(null);
    } else if (filters.length == 1) {
      widget.onFilterChanged?.call(filters.first);
    } else {
      widget.onFilterChanged?.call(AndFilter<T>(filters));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: SearchFilterPanel<T>(
            onFilterChanged: (f) {
              _searchFilter = f;
              _updateFilter();
            },
          ),
        ),
        const SizedBox(width: 8),
        ...widget.filters.map((f) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: FilterButton<T>(
                filter: f,
                onToggle: (filter, selected) {
                  setState(() {
                    if (selected) {
                      _activeFilters.add(filter);
                    } else {
                      _activeFilters.remove(filter);
                    }
                  });
                  _updateFilter();
                },
              ),
            )),
      ],
    );
  }
}
