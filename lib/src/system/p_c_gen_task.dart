// Translation of pcgen.system.PCGenTask

import 'p_c_gen_task_event.dart';
import 'p_c_gen_task_listener.dart';
import 'progress_container.dart';

/// Abstract base task that reports progress to registered listeners.
abstract class PCGenTask implements ProgressContainer {
  int _progress = 0;
  int _maximum = 0;
  String? _message;

  final List<PCGenTaskListener> _listeners = [];

  void addPCGenTaskListener(PCGenTaskListener listener) =>
      _listeners.add(listener);

  void removePCGenTaskListener(PCGenTaskListener listener) =>
      _listeners.remove(listener);

  void run();

  @override
  int getMaximum() => _maximum;

  @override
  int getProgress() => _progress;

  @override
  String? getMessage() => _message;

  @override
  void setValues(int progress, int maximum) {
    _progress = progress;
    _maximum = maximum;
    fireProgressChangedEvent();
  }

  @override
  void setValuesWithMessage(String message, int progress, int maximum) {
    _message = message;
    _progress = progress;
    _maximum = maximum;
    fireProgressChangedEvent();
  }

  @override
  void setProgress(int progress) {
    _progress = progress;
    fireProgressChangedEvent();
  }

  @override
  void setProgressWithMessage(String message, int progress) {
    _message = message;
    _progress = progress;
    fireProgressChangedEvent();
  }

  @override
  void setMaximum(int maximum) {
    _maximum = maximum;
    fireProgressChangedEvent();
  }

  @override
  void fireProgressChangedEvent() {
    final event = PCGenTaskEvent(this);
    for (final l in List.of(_listeners)) {
      l.progressChanged(event);
    }
  }
}
