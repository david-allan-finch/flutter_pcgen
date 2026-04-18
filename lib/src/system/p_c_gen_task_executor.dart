// Translation of pcgen.system.PCGenTaskExecutor

import 'p_c_gen_task.dart';
import 'p_c_gen_task_event.dart';
import 'p_c_gen_task_listener.dart';
import 'progress_container.dart';

/// Runs a queue of PCGenTasks sequentially, aggregating their progress.
class PCGenTaskExecutor extends PCGenTask implements PCGenTaskListener {
  final List<PCGenTask> _tasks = [];
  PCGenTask? _currentTask;

  void addPCGenTask(PCGenTask task) => _tasks.add(task);

  @override
  void run() {
    for (final task in List.of(_tasks)) {
      _currentTask = task;
      task.addPCGenTaskListener(this);
      task.run();
      task.removePCGenTaskListener(this);
    }
    _tasks.clear();
    _currentTask = null;
  }

  @override
  void progressChanged(PCGenTaskEvent event) {
    final ct = _currentTask;
    if (ct != null) {
      setValuesWithMessage(
          ct.getMessage() ?? '',
          ct.getProgress(),
          ct.getMaximum());
    }
  }

  @override
  void errorOccurred(PCGenTaskEvent event) {
    final error = event.getErrorRecord();
    final errorEvent = PCGenTaskEvent(this, errorRecord: error);
    for (final l in List<PCGenTaskListener>.of([])) {
      l.errorOccurred(errorEvent);
    }
  }
}
