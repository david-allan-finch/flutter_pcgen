// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/fact/FactFacet.java

import '../../../enumeration/char_id.dart';

/// FactFacet stores basic String information about a Player Character.
class FactFacet {
  final Map<CharID, Map<dynamic, String>> _cache = {};

  Map<dynamic, String> _getConstructingInfo(CharID id) {
    return _cache.putIfAbsent(id, () => {});
  }

  Map<dynamic, String>? _getInfo(CharID id) {
    return _cache[id];
  }

  /// Sets a String to be contained in the FactFacet for the given PCStringKey
  /// and Player Character identified by the given CharID.
  void set(CharID id, dynamic key, String s) {
    _getConstructingInfo(id)[key] = s;
  }

  /// Returns a String contained in the FactFacet for the given PCStringKey and
  /// Player Character identified by the given CharID.
  String? get(CharID id, dynamic key) {
    Map<dynamic, String>? rci = _getInfo(id);
    if (rci != null) {
      return rci[key];
    }
    return null;
  }

  /// Copies the contents of the FactFacet from one Player Character to another.
  void copyContents(CharID source, CharID destination) {
    Map<dynamic, String>? sourceRCI = _getInfo(source);
    if (sourceRCI != null) {
      _getConstructingInfo(destination).addAll(sourceRCI);
    }
  }
}
