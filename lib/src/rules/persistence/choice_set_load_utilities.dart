// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.ChoiceSetLoadUtilities

import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'token_library.dart';
import 'token_utilities.dart';

/// Utility class for parsing CHOOSE token values into PrimitiveCollection
/// and QualifierToken objects.
///
/// The Java source uses complex generic type hierarchies (PrimitiveCollection,
/// QualifierToken, etc.). In this Dart port those are represented as [dynamic]
/// until the full primitive/qualifier infrastructure is ported.
///
/// Translation of pcgen.rules.persistence.ChoiceSetLoadUtilities.
final class ChoiceSetLoadUtilities {
  ChoiceSetLoadUtilities._(); // prevent instantiation

  static const String _errInQual = 'Found error in Qualifier Choice: ';
  static const String _errInPrim = 'Found error in Primitive Choice: ';

  // ---------------------------------------------------------------------------
  // Top-level entry points
  // ---------------------------------------------------------------------------

  /// Parses [joinedOr] — a pipe-separated list of comma-separated primitives /
  /// qualifiers — into a PrimitiveCollection (returned as dynamic until the
  /// generic hierarchy is ported).
  ///
  /// Returns null on any parse error.
  static dynamic getChoiceSet(
      LoadContext context, dynamic selectionCreator, String joinedOr) {
    final orItems = _splitRespectingGrouping(joinedOr, '|');
    if (orItems == null) return null;

    final orList = <dynamic>[];
    for (final joinedAnd in orItems) {
      if (_hasIllegalSeparator(',', joinedAnd)) return null;
      final andItems = _splitRespectingGrouping(joinedAnd, ',');
      if (andItems == null) return null;

      final andList = <dynamic>[];
      for (final primitive in andItems) {
        if (primitive.isEmpty) {
          print('LST_ERROR: Choice argument was null or empty: $primitive');
          return null;
        }
        // Try qualifier first.
        final qual = getQualifier(context, selectionCreator, primitive);
        if (qual != null) {
          andList.add(qual);
        } else {
          final pcf = getSimplePrimitive(context, selectionCreator, primitive);
          if (pcf == null) {
            print('LST_ERROR: Choice argument was not valid: $primitive');
            return null;
          }
          andList.add(pcf);
        }
      }
      if (andList.length == 1) {
        orList.add(andList.first);
      } else if (andList.isNotEmpty) {
        orList.add(_CompoundAnd(andList)); // AND combination
      }
    }
    if (orList.isEmpty) return null;
    if (orList.length == 1) return orList.first;
    return _CompoundOr(orList); // OR combination
  }

  /// Parses a pipe-separated primitive list (no qualifiers allowed).
  static dynamic getPrimitive(
      LoadContext context, dynamic selectionCreator, String joinedOr) {
    if (joinedOr.isEmpty || _hasIllegalSeparator('|', joinedOr)) return null;

    final orItems = _splitRespectingGrouping(joinedOr, '|');
    if (orItems == null) return null;

    final orList = <dynamic>[];
    for (final joinedAnd in orItems) {
      if (joinedAnd.isEmpty || _hasIllegalSeparator(',', joinedAnd)) return null;
      final andItems = _splitRespectingGrouping(joinedAnd, ',');
      if (andItems == null) return null;

      final andList = <dynamic>[];
      for (final primitive in andItems) {
        if (primitive.isEmpty) {
          print('LST_ERROR: Choice argument was null or empty: $primitive');
          return null;
        }
        final pcf = getSimplePrimitive(context, selectionCreator, primitive);
        if (pcf == null) {
          print('LST_ERROR: Choice argument was not valid: $primitive');
          return null;
        }
        andList.add(pcf);
      }
      orList.add(andList.length == 1 ? andList.first : _CompoundAnd(andList));
    }
    return orList.length == 1 ? orList.first : _CompoundOr(orList);
  }

  // ---------------------------------------------------------------------------
  // Primitive / Qualifier resolution
  // ---------------------------------------------------------------------------

  /// Parses the structural information from a primitive key string.
  static PrimitiveInfo? getPrimitiveInfo(String key) {
    final openBracket = key.indexOf('[');
    final closeBracket = key.indexOf(']');
    final equal = key.indexOf('=');
    final pi = PrimitiveInfo();
    pi.key = key;

    if (openBracket == -1) {
      if (closeBracket != -1) {
        print('$_errInPrim$key has a close bracket but no open bracket');
        return null;
      }
      if (equal == -1) {
        pi.tokKey = key;
        pi.tokValue = null;
      } else {
        pi.tokKey = key.substring(0, equal);
        pi.tokValue = key.substring(equal + 1);
        if (pi.tokValue!.isEmpty) {
          print('$_errInPrim$key has equals but no target value');
          return null;
        }
      }
      pi.tokRestriction = null;
    } else {
      if (closeBracket == -1) {
        print('$_errInPrim$key has an open bracket but no close bracket');
        return null;
      }
      if (closeBracket != key.length - 1) {
        print('$_errInPrim$key had close bracket but trailing characters');
        return null;
      }
      if (equal == -1 || equal > openBracket) {
        pi.tokKey = key.substring(0, openBracket);
        pi.tokValue = null;
      } else {
        pi.tokKey = key.substring(0, equal);
        pi.tokValue = key.substring(equal + 1, openBracket);
      }
      pi.tokRestriction = key.substring(openBracket + 1, closeBracket);
    }
    return pi;
  }

  /// Resolves a single primitive or type reference from [key].
  static dynamic getSimplePrimitive(
      LoadContext context, dynamic selectionCreator, String key) {
    final pi = getPrimitiveInfo(key);
    if (pi == null) return null;

    // 1. Try plugin primitive token.
    final prim = _getTokenPrimitive(context, selectionCreator, pi);
    if (prim != null) return prim;

    // 2. Try dynamic group definition.
    // TODO: implement getDynamicGroup lookup once GroupDefinition is ported.

    // 3. Traditional: TYPE, !TYPE, ALL, pattern.
    return _getTraditionalPrimitive(context, selectionCreator, pi);
  }

  static dynamic _getTokenPrimitive(
      LoadContext context, dynamic selectionCreator, PrimitiveInfo pi) {
    // TODO: look up PrimitiveToken via TokenLibrary.getPrimitive and initialise.
    return null;
  }

  static dynamic _getTraditionalPrimitive(
      LoadContext context, dynamic sc, PrimitiveInfo pi) {
    final tokKey = pi.tokKey;
    if (tokKey == null) return null;

    if (pi.tokRestriction != null) {
      print('ERROR: Unexpected tokRestriction on $tokKey: ${pi.tokRestriction}');
      return null;
    }

    final tokValue = pi.tokValue;
    if (tokKey == 'TYPE') {
      return TokenUtilities.getTypeReference(context, dynamic, tokValue ?? '');
    }
    if (tokKey == '!TYPE') {
      final ref = TokenUtilities.getTypeReference(context, dynamic, tokValue ?? '');
      return ref == null ? null : _Negating(ref); // negate
    }
    if (tokValue != null) {
      print('ERROR: Unexpected arguments: $tokValue in ${pi.key}');
    }
    if (tokKey == 'ALL') return _AllReference();
    final k = pi.key ?? tokKey;
    if (k.startsWith('TYPE.')) {
      return TokenUtilities.getTypeReference(context, dynamic, k.substring(5));
    }
    if (k.startsWith('!TYPE.')) {
      final ref = TokenUtilities.getTypeReference(context, dynamic, k.substring(6));
      return ref == null ? null : _Negating(ref);
    }
    if (k.contains('%')) {
      return _PatternReference(k); // wildcard pattern
    }
    return context.getReferenceContext()?.getReference(dynamic, k);
  }

  /// Parses a qualifier token from [key] (e.g. "PC[WEAPONPROF=Longsword]").
  static dynamic getQualifier(
      LoadContext context, dynamic selectionCreator, String key) {
    if (key.isEmpty) {
      print('$_errInQual item was null or empty');
      return null;
    }
    final openBracket = key.indexOf('[');
    final closeBracket = key.indexOf(']');
    final equal = key.indexOf('=');
    final startsNot = key.startsWith('!');

    String tokKey;
    String? tokValue;
    String? tokRestriction;

    if (openBracket == -1) {
      if (closeBracket != -1) {
        print('$_errInQual$key has a close bracket but no open bracket');
        return null;
      }
      if (equal == -1) {
        tokKey = key;
        tokValue = null;
      } else {
        tokKey = key.substring(0, equal);
        tokValue = key.substring(equal + 1);
      }
      tokRestriction = null;
    } else {
      if (closeBracket == -1) {
        print('$_errInQual$key has an open bracket but no close bracket');
        return null;
      }
      if (closeBracket != key.length - 1) {
        print('$_errInQual$key had close bracket but trailing characters');
        return null;
      }
      if (closeBracket - openBracket == 1) {
        print('$_errInQual$key has empty brackets');
        return null;
      }
      if (equal == -1 || equal > openBracket) {
        tokKey = key.substring(0, openBracket);
        tokValue = null;
      } else {
        tokKey = key.substring(0, equal);
        tokValue = key.substring(equal + 1, openBracket);
      }
      tokRestriction = key.substring(openBracket + 1, closeBracket);
    }

    if (startsNot) tokKey = tokKey.substring(1);

    // TODO: iterate QualifierTokenIterator(selectionCreator.getReferenceClass(),
    //       tokKey) and call token.initialize(…) when QualifierToken is ported.
    return null;
  }

  // ---------------------------------------------------------------------------
  // Separator helpers
  // ---------------------------------------------------------------------------

  static bool _hasIllegalSeparator(String sep, String value) {
    if (value.startsWith(sep)) {
      print('LST_ERROR: Choice arguments may not start with $sep : $value');
      return true;
    }
    if (value.endsWith(sep)) {
      print('LST_ERROR: Choice arguments may not end with $sep : $value');
      return true;
    }
    if (value.contains('$sep$sep')) {
      print('LST_ERROR: Choice arguments use double separator $sep$sep : $value');
      return true;
    }
    return false;
  }

  /// Splits [input] by [separator] while respecting [ ] and ( ) groupings.
  /// Returns null if [input] is empty.
  static List<String>? _splitRespectingGrouping(String input, String separator) {
    if (input.isEmpty) return null;
    final result = <String>[];
    final buf = StringBuffer();
    int depth = 0;
    for (int i = 0; i < input.length; i++) {
      final ch = input[i];
      if (ch == '[' || ch == '(') {
        depth++;
        buf.write(ch);
      } else if (ch == ']' || ch == ')') {
        depth--;
        buf.write(ch);
      } else if (ch == separator && depth == 0) {
        result.add(buf.toString());
        buf.clear();
      } else {
        buf.write(ch);
      }
    }
    result.add(buf.toString());
    return result;
  }
}

// ---------------------------------------------------------------------------
// Structural data class
// ---------------------------------------------------------------------------

/// Holds the parsed components of a primitive key expression.
class PrimitiveInfo {
  String? key;
  String? tokKey;
  String? tokValue;
  String? tokRestriction;
}

// ---------------------------------------------------------------------------
// Placeholder compound / reference objects
// ---------------------------------------------------------------------------

class _CompoundAnd {
  final List<dynamic> items;
  _CompoundAnd(this.items);
}

class _CompoundOr {
  final List<dynamic> items;
  _CompoundOr(this.items);
}

class _Negating {
  final dynamic inner;
  _Negating(this.inner);
}

class _AllReference {}

class _PatternReference {
  final String pattern;
  _PatternReference(this.pattern);
}
