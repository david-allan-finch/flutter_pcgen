// Copyright 2016 Andrew Maitland <amaitland@users.sourceforge.net>
//
// Translation of pcgen.persistence.lst.TokenStore

import 'package:flutter_pcgen/src/persistence/lst/lst_token.dart';

/// A singleton store of LST tokens, organised by token-interface type.
class TokenStore {
  static TokenStore? _inst;

  /// Map from token-interface type tag → (tokenName → LstToken)
  final Map<String, Map<String, LstToken>> _tokenTypeMap = {};

  TokenStore._();

  static TokenStore inst() => _inst ??= TokenStore._();

  static void reset() {
    _inst?._tokenTypeMap.clear();
  }

  /// Registers [newToken] into all matching token maps.
  void addToTokenMap(String typeTag, LstToken newToken) {
    final tokenMap = getTokenMap(typeTag);
    final existing = tokenMap[newToken.getTokenName()];
    if (existing != null) {
      // TODO: log error — duplicate token name for type
    }
    tokenMap[newToken.getTokenName()] = newToken;
  }

  /// Returns the token map for the given [typeTag] (e.g. 'GameModeLstToken').
  Map<String, LstToken> getTokenMap(String typeTag) =>
      _tokenTypeMap.putIfAbsent(typeTag, () => {});
}
