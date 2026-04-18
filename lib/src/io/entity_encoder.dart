// Translation of pcgen.io.EntityEncoder

/// Encodes/decodes special characters in PCG files.
class EntityEncoder {
  static const Map<String, String> _encode = {
    '|': '%PIPE%',
    ':': '%COLON%',
    '\n': '%NEWLINE%',
    '\r': '%RETURN%',
    '\\': '%BACKSLASH%',
  };

  static final Map<String, String> _decode = {
    for (final e in _encode.entries) e.value: e.key
  };

  EntityEncoder._();

  static String encode(String s) {
    var result = s;
    for (final entry in _encode.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    return result;
  }

  static String decode(String s) {
    var result = s;
    for (final entry in _decode.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    return result;
  }
}
