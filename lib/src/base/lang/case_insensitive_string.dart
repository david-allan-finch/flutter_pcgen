class CaseInsensitiveString implements Comparable<CaseInsensitiveString> {
  final String _value;

  CaseInsensitiveString(String value) : _value = value;

  @override
  bool operator ==(Object other) {
    if (other is CaseInsensitiveString) {
      return _value.toLowerCase() == other._value.toLowerCase();
    }
    if (other is String) {
      return _value.toLowerCase() == other.toLowerCase();
    }
    return false;
  }

  @override
  int get hashCode => _value.toLowerCase().hashCode;

  @override
  int compareTo(CaseInsensitiveString other) =>
      _value.toLowerCase().compareTo(other._value.toLowerCase());

  @override
  String toString() => _value;
}
