//
// Copyright (c) 2006, 2009.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
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
