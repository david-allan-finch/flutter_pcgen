// *
// Copyright 2010 (C) James Dempsey
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
// Translation of pcgen.gui2.facade.TodoFacadeImpl

import '../../facade/core/todo_facade.dart';
import '../../util/enumeration/tab.dart';

/// Represents a task to be done for a character.
class TodoFacadeImpl implements TodoFacade, Comparable<TodoFacade> {
  final Tab tab;
  final String fieldName;
  final String messageKey;
  final int order;
  String? subTabName;

  /// Create a new todo task.
  TodoFacadeImpl(this.tab, this.fieldName, this.messageKey, this.order);

  /// Create a new todo task with a sub-tab name.
  TodoFacadeImpl.withSubTab(
      this.tab, this.fieldName, this.messageKey, this.subTabName, this.order);

  @override
  String getFieldName() => fieldName;

  @override
  String getMessageKey() => messageKey;

  @override
  Tab getTab() => tab;

  @override
  String? getSubTabName() => subTabName;

  @override
  int compareTo(TodoFacade that) {
    if (identical(this, that)) return 0;

    // Sort first by tab
    int tabCompare = tab.compareTo(that.getTab());
    if (tabCompare != 0) return tabCompare;

    // Then sort by order
    if (that is TodoFacadeImpl) {
      if (order > that.order) return 1;
      if (order < that.order) return -1;
      return fieldName.compareTo(that.fieldName);
    }
    return 0;
  }

  @override
  String toString() =>
      'TodoFacadeImpl{tab: $tab, field: $fieldName, msg: $messageKey}';
}
