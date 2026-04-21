// Translation of pcgen.gui2.filter.FilterBar

import 'package:flutter/material.dart';
import 'displayable_filter.dart';
import 'filter.dart';
import 'filter_button.dart';
import 'search_filter_panel.dart';

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
