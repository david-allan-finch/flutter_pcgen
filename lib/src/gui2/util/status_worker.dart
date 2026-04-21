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
