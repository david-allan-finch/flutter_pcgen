// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.CDOMSubLineLoader

import '../../rules/context/load_context.dart';

/// Generic loader for a named prefix within a multi-section LST file.
///
/// Each line handled by this loader must be a tab-separated sequence of
/// TOKEN:VALUE pairs; the first token's key serves as the section prefix.
///
/// [T] is the Loadable-like target type (constraint relaxed to avoid
/// needing a concrete Loadable import here).
///
/// Translation of pcgen.rules.persistence.CDOMSubLineLoader<T>.
class CDOMSubLineLoader<T> {
  final String _prefix;
  final String _prefixColon;
  final T Function() _factory;

  CDOMSubLineLoader(String prefix, T Function() factory)
      : _prefix = prefix,
        _prefixColon = '$prefix:',
        _factory = factory;

  /// The prefix key this loader is responsible for (e.g. "FACTDEF").
  String getPrefix() => _prefix;

  /// Creates a new blank instance of the target type.
  T getCDOMObject() => _factory();

  // ---------------------------------------------------------------------------
  // Parsing
  // ---------------------------------------------------------------------------

  /// Parses [val] (a tab-separated TOKEN:VALUE line) onto [obj].
  ///
  /// Returns true if every token was processed successfully.
  bool parseLine(LoadContext context, T obj, String val) {
    if (val.isEmpty) return true;

    bool returnValue = true;
    final tokens = val.split('\t');

    for (final rawToken in tokens) {
      final token = rawToken.trim();
      if (token.isEmpty) continue;

      final colonLoc = token.indexOf(':');
      if (colonLoc == -1) {
        print('ERROR: Invalid Token - does not contain a colon: $token');
        returnValue = false;
        continue;
      }
      if (colonLoc == 0) {
        print('ERROR: Invalid Token - starts with a colon: $token');
        returnValue = false;
        continue;
      }

      final key = token.substring(0, colonLoc);
      final value = colonLoc == token.length - 1
          ? null
          : token.substring(colonLoc + 1);

      if (value == null) {
        print('ERROR: Invalid token - key or value missing: $token in $val');
        returnValue = false;
        continue;
      }

      final passed = context.processToken(obj, key, value);
      if (passed) {
        context.commit();
      } else {
        context.rollback();
        returnValue = false;
      }
    }
    return returnValue;
  }

  // ---------------------------------------------------------------------------
  // Unparsing
  // ---------------------------------------------------------------------------

  /// Appends the unparse output for [object] to [sb].
  ///
  /// Tokens whose name starts with [_prefixColon] are written first (as the
  /// section header); all others follow, tab-separated.
  void unloadObject(LoadContext context, T object, StringBuffer sb) {
    final unparsed = context.unparse(object);
    if (unparsed == null) return;

    final rest = StringBuffer();
    for (final s in unparsed) {
      if (s.startsWith(_prefixColon)) {
        sb.write(s);
      } else {
        rest.write('\t');
        rest.write(s);
      }
    }
    sb.write(rest);
    sb.write('\n');
  }
}
