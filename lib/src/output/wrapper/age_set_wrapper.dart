// Translation of pcgen.output.wrapper.AgeSetWrapper

import '../base/simple_object_wrapper.dart';
import '../model/age_set_model.dart';

/// Wraps AgeSet objects into output models.
class AgeSetWrapper implements SimpleObjectWrapper {
  @override
  dynamic wrap(Object obj) {
    // TODO: check for AgeSet type when AgeSet is defined
    return AgeSetModel(obj);
  }
}
