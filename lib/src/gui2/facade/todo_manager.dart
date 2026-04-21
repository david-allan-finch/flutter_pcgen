// *
// Copyright James Dempsey, 2011
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
// Translation of pcgen.gui2.facade.TodoManager

import 'package:flutter_pcgen/src/facade/core/todo_facade.dart';
import 'package:flutter_pcgen/src/facade/util/default_list_facade.dart';
import 'package:flutter_pcgen/src/facade/util/list_facade.dart';

/// Tracks an unordered list of user tasks.
/// Each task is a TodoFacade instance with enough information to direct the
/// user to the field where they can achieve the task.
class TodoManager {
  final DefaultListFacade<TodoFacade> _todoList = DefaultListFacade();

  TodoManager();

  ListFacade<TodoFacade> getTodoList() => _todoList;

  /// Add a task to be done to the todo list, if it is not already there.
  void addTodo(TodoFacade item) {
    if (_findTodoByMessage(item.getMessageKey(), item.getFieldName()) == null) {
      _todoList.addElement(item);
    }
  }

  /// Remove a task to be done from the todo list by message key.
  void removeTodo(String messageKey, [String? fieldName]) {
    TodoFacade? found = _findTodoByMessage(messageKey, fieldName);
    if (found != null) {
      _todoList.removeElement(found);
    }
  }

  /// Search the todo list for an item with the specified messageKey.
  /// [fieldName] may be null to match any field name.
  TodoFacade? _findTodoByMessage(String? messageKey, String? fieldName) {
    if (messageKey == null) return null;
    for (TodoFacade item in _todoList) {
      if (messageKey == item.getMessageKey()) {
        if (fieldName == null || fieldName == item.getFieldName()) {
          return item;
        }
      }
    }
    return null;
  }
}
