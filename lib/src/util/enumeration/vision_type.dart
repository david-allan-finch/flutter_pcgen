import 'package:pcgen2/src/base/lang/case_insensitive_string.dart';

/// A dynamic (non-enum) type registry for vision types.
///
/// New types are registered on first access via [getVisionType]. Each unique
/// name maps to a single [VisionType] instance (case-insensitive). This mirrors
/// the Java implementation which used a lazy-built identity map.
final class VisionType {
  static final Map<CaseInsensitiveString, VisionType> _typeMap = {};

  VisionType._();

  static VisionType getVisionType(String s) {
    final key = CaseInsensitiveString(s);
    return _typeMap.putIfAbsent(key, VisionType._);
  }

  /// Resets the registry to the built-in set (clears any runtime-added types).
  static void clearConstants() {
    _typeMap.clear();
  }

  static Iterable<VisionType> getAllVisionTypes() =>
      List.unmodifiable(_typeMap.values);

  @override
  String toString() {
    for (final entry in _typeMap.entries) {
      if (entry.value == this) return entry.key.toString();
    }
    return '';
  }
}
