// Translation of pcgen.output.wrapper.DateWrapper

import '../base/simple_object_wrapper.dart';
import '../model/date_model.dart';

/// Wraps DateTime objects into output models.
class DateWrapper implements SimpleObjectWrapper {
  @override
  dynamic wrap(Object obj) {
    if (obj is DateTime) return DateModel(obj);
    throw StateError('DateWrapper: cannot wrap ${obj.runtimeType}');
  }
}
