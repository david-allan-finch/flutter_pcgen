// Splits a grouping string into tokens on '=', '[', and ']' delimiters.
class GroupingTokenizer implements Iterator<String> {
  final List<String> _tokens;
  int _index = 0;
  bool _peeked = false;
  String? _peekedString;
  final StringBuffer _consumed;

  factory GroupingTokenizer(String string) {
    final tokens = _tokenize(string);
    return GroupingTokenizer._(tokens, StringBuffer());
  }

  GroupingTokenizer._(this._tokens, this._consumed);

  static List<String> _tokenize(String s) {
    final result = <String>[];
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final c = s[i];
      if (c == '=' || c == '[' || c == ']') {
        if (buf.isNotEmpty) {
          result.add(buf.toString());
          buf.clear();
        }
        result.add(c);
      } else {
        buf.write(c);
      }
    }
    if (buf.isNotEmpty) result.add(buf.toString());
    return result;
  }

  @override
  bool get current => _index < _tokens.length;

  @override
  bool moveNext() => _index < _tokens.length;

  bool hasNext() => _peeked || _index < _tokens.length;

  @override
  String next() {
    if (_peeked) {
      _peeked = false;
      _consumed.write(_peekedString);
      return _peekedString!;
    }
    final val = _tokens[_index++];
    _consumed.write(val);
    return val;
  }

  String getConsumed() => _consumed.toString();

  String peek() {
    if (!_peeked) {
      _peekedString = _tokens[_index++];
      _peeked = true;
    }
    return _peekedString!;
  }
}
