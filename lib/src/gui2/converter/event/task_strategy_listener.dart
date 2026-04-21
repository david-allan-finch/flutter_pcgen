// Translation of pcgen.gui2.converter.event.TaskStrategyListener

/// Functional interface for receiving task status messages during conversion.
abstract class TaskStrategyListener {
  void processStatus(Object source, String message);
}

/// A [TaskStrategyListener] backed by a plain callback function.
class FunctionTaskStrategyListener implements TaskStrategyListener {
  final void Function(Object source, String message) _callback;

  FunctionTaskStrategyListener(this._callback);

  @override
  void processStatus(Object source, String message) =>
      _callback(source, message);
}
