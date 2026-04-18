// Parses a String separated by a given character, respecting parentheses nesting.
class ParsingSeparator {
  final String _input;
  final String _separator;
  int _index = 0;

  ParsingSeparator(this._input, this._separator);

  bool hasNext() => _index <= _input.length;

  String next() {
    if (_index > _input.length) throw StateError('No more tokens');
    int depth = 0;
    final buf = StringBuffer();
    int start = _index;
    while (_index < _input.length) {
      final ch = _input[_index];
      if (ch == '(') depth++;
      if (ch == ')') depth--;
      if (depth == 0 && _input.startsWith(_separator, _index)) {
        _index += _separator.length;
        return buf.toString();
      }
      buf.write(ch);
      _index++;
    }
    _index++; // mark as exhausted
    return buf.toString();
  }

  static List<String> split(String input, String separator) {
    final ps = ParsingSeparator(input, separator);
    final result = <String>[];
    while (ps.hasNext()) {
      result.add(ps.next());
    }
    return result;
  }
}
