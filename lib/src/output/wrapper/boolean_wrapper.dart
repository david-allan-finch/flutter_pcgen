// Translation of pcgen.output.wrapper.BooleanWrapper

import '../base/simple_object_wrapper.dart';
import '../model/boolean_model.dart';

/// Wraps Boolean objects into output models.
class BooleanWrapper implements SimpleObjectWrapper {
  @override
  dynamic wrap(Object obj) {
    if (obj is bool) return BooleanModel(obj);
    throw StateError('BooleanWrapper: cannot wrap ${obj.runtimeType}');
  }
}
