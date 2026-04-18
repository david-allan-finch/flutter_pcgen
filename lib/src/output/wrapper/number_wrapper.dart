// Translation of pcgen.output.wrapper.NumberWrapper

import '../base/simple_object_wrapper.dart';
import '../model/number_model.dart';

/// Wraps Number objects into output models.
class NumberWrapper implements SimpleObjectWrapper {
  @override
  dynamic wrap(Object obj) {
    if (obj is num) return NumberModel(obj);
    throw StateError('NumberWrapper: cannot wrap ${obj.runtimeType}');
  }
}
