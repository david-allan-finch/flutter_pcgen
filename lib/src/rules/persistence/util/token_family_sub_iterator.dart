// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.util.TokenFamilySubIterator

import 'package:flutter_pcgen/src/rules/persistence/token/c_d_o_m_secondary_token.dart';
import 'token_family.dart';

/// Iterates [CDOMSecondaryToken]s for a given parent-token name across the
/// type hierarchy within [TokenFamily.current].
///
/// As with [TokenFamilyIterator], Dart requires an explicit [typeHierarchy]
/// list because runtime supertype reflection is not available.  Token names
/// that already appeared in a more-specific type are skipped.
class TokenFamilySubIterator<C> implements Iterator<CDOMSecondaryToken<C>> {
  final List<Type> _typeHierarchy;
  final String _parentToken;
  int _typeIndex = 0;
  Iterator<CDOMSecondaryToken<dynamic>>? _subIterator;
  CDOMSecondaryToken<C>? _current;
  final Set<String> _used = {};
  bool _done = false;

  TokenFamilySubIterator(Type rootType, String parentToken,
      [List<Type>? typeHierarchy])
      : _typeHierarchy = typeHierarchy ?? [rootType],
        _parentToken = parentToken {
    _subIterator = TokenFamily.current
        .getSubTokens(_typeHierarchy[0], _parentToken)
        .iterator as Iterator<CDOMSecondaryToken<dynamic>>;
  }

  @override
  CDOMSecondaryToken<C> get current => _current!;

  @override
  bool moveNext() {
    while (!_done) {
      if (_subIterator != null && _subIterator!.moveNext()) {
        final tok = _subIterator!.current;
        if (tok is CDOMSecondaryToken<C>) {
          if (_used.contains(tok.getTokenName())) continue;
          _used.add(tok.getTokenName());
          _current = tok;
          return true;
        }
      } else {
        _typeIndex++;
        if (_typeIndex >= _typeHierarchy.length) {
          _done = true;
          return false;
        }
        _subIterator = TokenFamily.current
            .getSubTokens(_typeHierarchy[_typeIndex], _parentToken)
            .iterator as Iterator<CDOMSecondaryToken<dynamic>>;
      }
    }
    return false;
  }
}
