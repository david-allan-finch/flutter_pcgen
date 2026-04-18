// Translation of pcgen.output.wrapper.CDOMReferenceWrapper

import '../base/p_c_gen_object_wrapper.dart';
import '../base/simple_wrapper_library.dart';

/// Wraps CDOMReference objects (resolves them and wraps the resolved object).
class CDOMReferenceWrapper implements PCGenObjectWrapper {
  @override
  dynamic wrap(String charId, Object obj) {
    // TODO: resolve CDOMSingleRef and wrap the resolved object
    return SimpleWrapperLibrary.wrap(obj);
  }
}
