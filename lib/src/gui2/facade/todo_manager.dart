// Translation of pcgen.gui2.facade.TodoManager

import '../../facade/core/todo_facade.dart';
import '../../facade/util/default_list_facade.dart';
import '../../facade/util/list_facade.dart';

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
