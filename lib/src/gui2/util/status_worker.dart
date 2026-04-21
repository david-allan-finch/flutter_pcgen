//
// Missing License Header, Copyright 2016 (C) Andrew Maitland <amaitland@users.sourceforge.net>
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
// Translation of pcgen.gui2.util.StatusWorker

import 'dart:async';
import '../pc_gen_status_bar.dart';

typedef PCGenTask = dynamic;

/// Handles progress display in the status bar while executing a background task.
class StatusWorker {
  final String statusMsg;
  final PCGenTask task;
  final PCGenStatusBarState statusBar;
  bool _dirty = false;
  final List<dynamic> _errors = [];

  StatusWorker(this.statusMsg, this.task, this.statusBar);

  Future<List<dynamic>> execute() async {
    final oldMessage = statusBar.getContextMessage();
    statusBar.startShowingProgress(statusMsg, false);

    try {
      await _runTask();
    } catch (e) {
      // log error
    }

    statusBar.setContextMessage(oldMessage);
    statusBar.endShowingProgress();
    return List.unmodifiable(_errors);
  }

  Future<void> _runTask() async {
    // Run the task on a background isolate / async
    final progress = task?.getProgress as int? ?? 0;
    final maximum = task?.getMaximum as int? ?? 100;

    if (task != null) {
      await Future(() => task.run());
    }
  }

  void progressChanged(dynamic event) {
    if (!_dirty) {
      _dirty = true;
      final progress = task?.getProgress as int? ?? 0;
      final maximum = task?.getMaximum as int? ?? 100;
      statusBar.updateProgress(
          maximum > 0 ? progress / maximum : 0.0,
          task?.getMessage as String?);
      _dirty = false;
    }
  }

  void errorOccurred(dynamic event) {
    _errors.add(event.errorRecord);
  }

  List<dynamic> getErrors() => List.unmodifiable(_errors);
}
