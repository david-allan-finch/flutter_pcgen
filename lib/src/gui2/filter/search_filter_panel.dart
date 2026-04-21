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
