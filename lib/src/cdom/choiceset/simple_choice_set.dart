//
// Copyright 2006 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.cdom.choiceset.SimpleChoiceSet
import '../base/constants.dart';
import '../enumeration/grouping_state.dart';

// A PrimitiveChoiceSet that holds a fixed collection of objects.
// Contents do not vary by PlayerCharacter.
class SimpleChoiceSet<T> {
  // Optional comparator for sorting; null means no guaranteed order in getLSTformat.
  final Comparator<T>? _comparator;

  // The underlying set of objects (insertion-ordered, no duplicates).
  final LinkedSet<T> _set;

  // The separator used for LST format output.
  final String _separator;

  SimpleChoiceSet(List<T> col)
      : this._full(col, null, null);

  SimpleChoiceSet.withSeparator(List<T> col, String separator)
      : this._full(col, null, separator);

  SimpleChoiceSet.withComparator(List<T> col, Comparator<T> comp)
      : this._full(col, comp, null);

  SimpleChoiceSet._full(List<T> col, Comparator<T>? comp, String? sep)
      : _comparator = comp,
        _set = LinkedSet<T>(),
        _separator = sep ?? Constants.comma {
    if (col.isEmpty) {
      throw ArgumentError('Choice Collection cannot be empty');
    }
    for (final T item in col) {
      if (!_set.add(item)) {
        throw ArgumentError('Choice Collection cannot possess a duplicate item');
      }
    }
  }

  String getLSTformat(bool useAny) {
    List<T> sortingList = List<T>.from(_set._items);
    if (_comparator != null) {
      try {
        sortingList.sort(_comparator);
      } catch (_) {
        // Fallback to insertion order if sorting fails (e.g., ClassCastException).
      }
    }
    return sortingList.map((e) => e.toString()).join(_separator);
  }

  Type getChoiceClass() {
    return _set._items.isEmpty ? dynamic : _set._items.first.runtimeType;
  }

  // Returns a new set containing all items (independent copy).
  Set<T> getSet(dynamic pc) {
    return Set<T>.from(_set._items);
  }

  @override
  int get hashCode => _set._items.length;

  @override
  bool operator ==(Object obj) {
    if (identical(this, obj)) return true;
    if (obj is SimpleChoiceSet<T>) {
      final myItems = _set._items;
      final otherItems = obj._set._items;
      if (myItems.length != otherItems.length) return false;
      for (final item in myItems) {
        if (!otherItems.contains(item)) return false;
      }
      return true;
    }
    return false;
  }

  GroupingState getGroupingState() => GroupingState.any;
}

// Minimal linked-insertion-order set helper (no external dependency needed).
class LinkedSet<T> {
  final List<T> _items = [];

  bool add(T item) {
    if (_items.contains(item)) return false;
    _items.add(item);
    return true;
  }
}
