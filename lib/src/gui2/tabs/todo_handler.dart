// Translation of pcgen.gui2.tabs.TodoHandler

/// Defines a tab capable of advising the user of which field should be used
/// to action a todo item. The tab may highlight the field or change focus to it.
abstract interface class TodoHandler {
  /// Advise the user of where to action a todo item.
  ///
  /// [fieldName] is the name of the field to be actioned.
  void adviseTodo(String fieldName);
}
