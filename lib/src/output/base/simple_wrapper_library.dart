// Translation of pcgen.output.base.SimpleWrapperLibrary

import 'simple_object_wrapper.dart';
import '../wrapper/string_wrapper.dart';
import '../wrapper/number_wrapper.dart';
import '../wrapper/boolean_wrapper.dart';
import '../wrapper/type_safe_constant_wrapper.dart';
import '../wrapper/category_wrapper.dart';
import '../wrapper/enum_wrapper.dart';
import '../wrapper/ordered_pair_wrapper.dart';
import '../wrapper/age_set_wrapper.dart';

/// SimpleWrapperLibrary stores information on simple wrappers used to wrap
/// objects into output models.
final class SimpleWrapperLibrary {
  SimpleWrapperLibrary._();

  static final List<SimpleObjectWrapper> _wrapperList = [
    StringWrapper(),
    NumberWrapper(),
    BooleanWrapper(),
    TypeSafeConstantWrapper(),
    CategoryWrapper(),
    EnumWrapper(),
    OrderedPairWrapper(),
    AgeSetWrapper(),
  ];

  /// Wraps the given object using the first wrapper that succeeds.
  static dynamic wrap(Object? toWrap) {
    if (toWrap == null) return null;
    for (final ow in _wrapperList) {
      try {
        return ow.wrap(toWrap);
      } catch (_) {
        // Try next wrapper
      }
    }
    throw StateError('Unable to find wrapping for ${toWrap.runtimeType}');
  }
}
