// Translation of pcgen.output.wrapper.OrderedPairWrapper

import '../base/simple_object_wrapper.dart';
import '../model/ordered_pair_model.dart';

/// Wraps OrderedPair objects into output models.
class OrderedPairWrapper implements SimpleObjectWrapper {
  @override
  dynamic wrap(Object obj) {
    // TODO: check for OrderedPair type when defined
    return OrderedPairModel(obj);
  }
}
