// Translation of pcgen.output.wrapper.EnumWrapper

import '../base/simple_object_wrapper.dart';
import '../base/simple_wrapper_library.dart';

/// Wraps Enum objects into output models (via toString).
class EnumWrapper implements SimpleObjectWrapper {
  @override
  dynamic wrap(Object obj) {
    if (obj is Enum) return SimpleWrapperLibrary.wrap(obj.name);
    throw StateError('EnumWrapper: cannot wrap ${obj.runtimeType}');
  }
}
