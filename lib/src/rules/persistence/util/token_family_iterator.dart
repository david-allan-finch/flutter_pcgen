// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.util.TokenFamilyIterator

import 'package:flutter_pcgen/src/rules/persistence/token/c_d_o_m_primary_token.dart';
import 'package:flutter_pcgen/src/rules/persistence/token/c_d_o_m_token.dart';
import 'token_family.dart';

/// Iterates [CDOMPrimaryToken]s for a given type across the type hierarchy
/// within [TokenFamily.current].
///
/// Dart has no runtime supertype reflection, so callers pass an explicit
/// [typeHierarchy] list ordered from most-specific to least-specific
/// (e.g. `[Race, CDOMObject]`).  Tokens registered against a broader type
/// are skipped when a more-specific token with the same name already exists.
class TokenFamilyIterator<C> implements Iterator<CDOMPrimaryToken<C>> {
  final List<Type> _typeHierarchy;
  int _typeIndex = 0;
  Iterator<CDOMToken<dynamic>>? _subIterator;
  CDOMPrimaryToken<C>? _current;
  final Set<String> _used = {};
  bool _done = false;

  TokenFamilyIterator(Type rootType, [List<Type>? typeHierarchy])
      : _typeHierarchy = typeHierarchy ?? [rootType] {
    _subIterator =
        TokenFamily.current.getTokens(_typeHierarchy[0]).iterator;
  }

  @override
  CDOMPrimaryToken<C> get current => _current!;

  @override
  bool moveNext() {
    while (!_done) {
      if (_subIterator != null && _subIterator!.moveNext()) {
        final tok = _subIterator!.current;
        if (tok is CDOMPrimaryToken<C>) {
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
        _subIterator =
            TokenFamily.current.getTokens(_typeHierarchy[_typeIndex]).iterator;
      }
    }
    return false;
  }
}
