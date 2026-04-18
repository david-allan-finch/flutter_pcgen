// Represents dice roll notation: NdS/top\bottom|list mX MY +mod tfloor Tceil
final class RollInfo {
  int sides = 0;
  int times = 0;
  List<bool>? keepList;
  int modifier = 0;
  int rerollAbove = 0x7fffffff;
  int rerollBelow = -0x80000000;
  int totalCeiling = 0x7fffffff;
  int totalFloor = -0x80000000;

  RollInfo._();

  /// Parse a roll string like "4d6/3", "2d8+2", "1d20m2T30".
  factory RollInfo(String rollString) {
    final ri = RollInfo._();
    final err = _parse(ri, rollString);
    if (err.isNotEmpty) print('RollInfo parse error: $err');
    return ri;
  }

  static String validate(String rollString) => _parse(RollInfo._(), rollString);

  static String _parse(RollInfo ri, String s) {
    try {
      int i = 0;
      // Read optional times
      int dPos = s.indexOf('d');
      if (dPos < 0) return "Missing 'd' in '$s'";
      if (dPos == 0) {
        ri.times = 1;
      } else {
        ri.times = int.parse(s.substring(0, dPos));
      }
      i = dPos + 1;
      // Read sides up to modifier chars
      const mods = '/\\|mM+-tT';
      int end = i;
      while (end < s.length && !mods.contains(s[end])) end++;
      if (end == i) return "Missing sides in '$s'";
      ri.sides = int.parse(s.substring(i, end));
      if (ri.sides < 1) return "Sides < 1 in '$s'";
      i = end;

      while (i < s.length) {
        final c = s[i];
        i++;
        switch (c) {
          case '/':
            final (val, ni) = _readInt(s, i);
            i = ni;
            ri.keepList = List.filled(ri.times, false);
            for (int k = ri.times - val; k < ri.times; k++) ri.keepList![k] = true;
          case r'\':
            final (val, ni) = _readInt(s, i);
            i = ni;
            ri.keepList = List.filled(ri.times, false);
            for (int k = 0; k < val; k++) ri.keepList![k] = true;
          case '|':
            final (raw, ni) = _readUntilMod(s, i);
            i = ni;
            ri.keepList = List.filled(ri.times, false);
            for (final idx in raw.split(',')) {
              ri.keepList![int.parse(idx) - 1] = true;
            }
          case 'm':
            final (val, ni) = _readInt(s, i);
            i = ni;
            ri.rerollBelow = val;
          case 'M':
            final (val, ni) = _readInt(s, i);
            i = ni;
            ri.rerollAbove = val;
          case '+':
            final (val, ni) = _readInt(s, i);
            i = ni;
            ri.modifier = val;
          case '-':
            final (val, ni) = _readInt(s, i);
            i = ni;
            ri.modifier = -val;
          case 't':
            final (val, ni) = _readInt(s, i);
            i = ni;
            ri.totalFloor = val;
          case 'T':
            final (val, ni) = _readInt(s, i);
            i = ni;
            ri.totalCeiling = val;
        }
      }
      return '';
    } catch (e) {
      return "Bad roll string '$s': $e";
    }
  }

  static (int, int) _readInt(String s, int start) {
    int end = start;
    if (end < s.length && (s[end] == '+' || s[end] == '-')) end++;
    while (end < s.length && '0123456789'.contains(s[end])) end++;
    return (int.parse(s.substring(start, end)), end);
  }

  static (String, int) _readUntilMod(String s, int start) {
    const mods = 'mM+-tT';
    int end = start;
    while (end < s.length && !mods.contains(s[end])) end++;
    return (s.substring(start, end), end);
  }

  @override
  String toString() {
    final buf = StringBuffer();
    if (times > 0) buf.write(times);
    buf.write('d$sides');
    if (keepList != null) {
      // Determine if top/bottom/list
      final kl = keepList!;
      bool allTrue = kl.every((b) => b);
      if (!allTrue) {
        int firstTrue = kl.indexWhere((b) => b);
        int lastFalse = kl.lastIndexWhere((b) => !b);
        if (firstTrue > 0 && kl.sublist(firstTrue).every((b) => b)) {
          buf.write('\\$firstTrue');
        } else if (lastFalse >= 0 && kl.sublist(0, lastFalse + 1).every((b) => !b) && kl.sublist(lastFalse + 1).every((b) => b)) {
          buf.write('/${times - lastFalse - 1}');
        } else {
          buf.write('|');
          bool first = true;
          for (int i = 0; i < kl.length; i++) {
            if (kl[i]) { if (!first) buf.write(','); buf.write(i + 1); first = false; }
          }
        }
      }
    }
    if (rerollBelow != -0x80000000) buf.write('m$rerollBelow');
    if (rerollAbove != 0x7fffffff) buf.write('M$rerollAbove');
    if (modifier > 0) buf.write('+$modifier');
    else if (modifier < 0) buf.write('${modifier}');
    if (totalFloor != -0x80000000) buf.write('t$totalFloor');
    if (totalCeiling != 0x7fffffff) buf.write('T$totalCeiling');
    return buf.toString();
  }
}
