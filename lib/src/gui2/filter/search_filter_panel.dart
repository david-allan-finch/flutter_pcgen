// Translation of pcgen.gui2.filter.SearchFilterPanel

import 'package:flutter/material.dart';
import 'filter.dart';
import 'filter_utilities.dart';

/// A search panel that creates a text-search filter on input.
class SearchFilterPanel<T> extends StatefulWidget {
  final void Function(Filter<T>? filter)? onFilterChanged;

  const SearchFilterPanel({super.key, this.onFilterChanged});

  @override
  State<SearchFilterPanel<T>> createState() => _SearchFilterPanelState<T>();
}

class _SearchFilterPanelState<T> extends State<SearchFilterPanel<T>> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    if (query.isEmpty) {
      widget.onFilterChanged?.call(null);
    } else {
      widget.onFilterChanged?.call(FilterUtilities.textSearch<T>(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.search, size: 16),
        hintText: 'Search...',
        isDense: true,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      onChanged: _onChanged,
    );
  }
}
