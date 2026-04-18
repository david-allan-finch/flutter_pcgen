import '../content/processor.dart';

// A Processor that conditionally applies an underlying Processor based on context.
class ContextProcessor<T, R> implements Processor<T> {
  final Processor<T> _processor;
  final dynamic _contextItems; // CDOMReference<R>

  ContextProcessor(Processor<T> mod, dynamic contextRef)
      : _processor = mod,
        _contextItems = contextRef;

  @override
  T applyProcessor(T input, Object? context) {
    if (context != null && _contextItems.contains(context)) {
      return _processor.applyProcessor(input, context);
    }
    return input;
  }

  @override
  String getLSTformat() =>
      '${_contextItems.getLSTformat()}|${_processor.getLSTformat()}';

  @override
  Type getModifiedClass() => _processor.getModifiedClass();

  @override
  int get hashCode => _processor.hashCode * 29 + _contextItems.hashCode;

  @override
  bool operator ==(Object obj) =>
      obj is ContextProcessor &&
      obj._processor == _processor &&
      obj._contextItems == _contextItems;
}
