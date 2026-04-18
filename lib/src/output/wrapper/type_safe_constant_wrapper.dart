// Translation of pcgen.output.wrapper.TypeSafeConstantWrapper

import '../base/simple_object_wrapper.dart';
import '../base/simple_wrapper_library.dart';

/// Wraps TypeSafeConstant objects into output models (via toString).
class TypeSafeConstantWrapper implements SimpleObjectWrapper {
  @override
  dynamic wrap(Object obj) {
    // TypeSafeConstant in Dart doesn't have a common interface; wrap via toString
    // TODO: check for TypeSafeConstant interface when defined
    return SimpleWrapperLibrary.wrap(obj.toString());
  }
}
