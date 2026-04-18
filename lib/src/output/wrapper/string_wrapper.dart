// Translation of pcgen.output.wrapper.StringWrapper

import '../base/simple_object_wrapper.dart';
import '../model/string_model.dart';

/// Wraps String objects into output models.
class StringWrapper implements SimpleObjectWrapper {
  @override
  dynamic wrap(Object obj) {
    if (obj is String) return StringModel(obj);
    throw StateError('StringWrapper: cannot wrap ${obj.runtimeType}');
  }
}
