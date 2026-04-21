//
// Copyright 2018 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under the terms
// of the GNU Lesser General Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along with
// this library; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
// Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.cdom.grouping.GroupingScopeFilter
import 'grouping_collection.dart';

// Decorates a GroupingCollection to filter by PCGenScope name.
class GroupingScopeFilter<T> implements GroupingCollection<T> {
  final GroupingCollection<T> _underlying;
  final String _scopeName;

  GroupingScopeFilter(GroupingCollection<T> underlying, String scopeName)
      : _underlying = underlying,
        _scopeName = scopeName;

  @override
  String getInstructions() => _underlying.getInstructions();

  @override
  void process(dynamic target, void Function(dynamic) consumer) {
    // Only pass to underlying if the target's scope name matches
    final scope = target.getLocalScopeName?.call();
    if (scope == null || scope == _scopeName) {
      _underlying.process(target, consumer);
    }
  }
}
