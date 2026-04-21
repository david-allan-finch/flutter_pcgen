// Translation of pcgen.gui2.converter.event.TaskStrategyMessage

import 'task_strategy_listener.dart';

/// Static broadcaster for task-strategy status messages.
/// Listeners register via [addTaskStrategyListener] and receive
/// notifications via [sendStatus].
class TaskStrategyMessage {
  TaskStrategyMessage._();

  static final List<TaskStrategyListener> _listeners = [];

  /// Broadcasts [message] from [source] to all registered listeners.
  static void sendStatus(Object source, String message) {
    for (final listener in List.of(_listeners)) {
      listener.processStatus(source, message);
    }
  }

  /// Registers [listener] to receive future status messages.
  static void addTaskStrategyListener(TaskStrategyListener listener) {
    _listeners.add(listener);
  }

  /// Removes a previously registered [listener].
  static void removeTaskStrategyListener(TaskStrategyListener listener) {
    _listeners.remove(listener);
  }
}
