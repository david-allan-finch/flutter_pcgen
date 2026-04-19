// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.TokenUtilities

import '../../rules/context/load_context.dart';
import 'token/c_d_o_m_token.dart';
import 'token_library.dart';

/// Utility methods for token lookup and reference construction.
///
/// Translation of pcgen.rules.persistence.TokenUtilities (utility statics).
final class TokenUtilities {
  TokenUtilities._(); // prevent instantiation

  // ---------------------------------------------------------------------------
  // Token lookup
  // ---------------------------------------------------------------------------

  /// Returns the first [CDOMToken] registered for [cl] and [tokenName], or
  /// null if none is found.
  static CDOMToken<dynamic>? getToken(Type cl, String tokenName) =>
      TokenLibrary.getToken(cl, tokenName);

  // ---------------------------------------------------------------------------
  // Reference construction helpers
  // ---------------------------------------------------------------------------

  /// Returns a reference (TYPE or primitive) for the given [s] string within
  /// [context] for objects of type [cl].
  ///
  /// If [s] begins with TYPE= or TYPE. the result is a type reference; if it
  /// begins with !TYPE= or !TYPE. the caller should negate the result.
  /// Otherwise a direct reference by name is returned.
  ///
  /// Returns null on error.
  static dynamic getTypeOrPrimitive(
      LoadContext context, Type cl, String s) {
    if (s.startsWith('TYPE.') || s.startsWith('TYPE=')) {
      return getTypeReference(context, cl, s.substring(5));
    }
    if (s.startsWith('!TYPE.') || s.startsWith('!TYPE=')) {
      print('ERROR: !TYPE not supported in token, found: $s');
      return null;
    }
    // Fallback: direct key reference.
    return context.getReferenceContext()?.getReference(cl, s);
  }

  /// Returns a group (type-filtered) reference for [subStr] within [context].
  ///
  /// [subStr] may be dot-delimited (e.g. "Martial.Melee") and must not start
  /// or end with a dot, nor contain consecutive dots.
  static dynamic getTypeReference(
      LoadContext context, Type cl, String subStr) {
    if (subStr.isEmpty) {
      print('ERROR: Type may not be empty');
      return null;
    }
    if (subStr.startsWith('.') || subStr.endsWith('.')) {
      print('ERROR: Type may not start or end with . in: $subStr');
      return null;
    }
    final types = subStr.split('.');
    for (final type in types) {
      if (type.isEmpty) {
        print('ERROR: Empty type segment in: $subStr');
        return null;
      }
    }
    // TODO: delegate to context.getReferenceContext().getTypeReference(types)
    //       once ReferenceManufacturer/SelectionCreator is ported.
    return null;
  }

  /// Returns a reference to [tokText] in [context] for [cl].
  ///
  /// If [tokText] is "ALL" the all-reference is returned; otherwise
  /// [getTypeOrPrimitive] is used.
  static dynamic getReference(
      LoadContext context, Type cl, String tokText) {
    if (tokText == 'ALL') {
      return context.getReferenceContext()?.getCDOMAllReference(cl);
    }
    return getTypeOrPrimitive(context, cl, tokText);
  }
}
