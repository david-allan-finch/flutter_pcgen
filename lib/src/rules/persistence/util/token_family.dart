// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.util.TokenFamily

import 'dart:collection';

import 'package:flutter_pcgen/src/persistence/lst/prereq/prerequisite_parser_interface.dart';
import 'package:flutter_pcgen/src/rules/persistence/token/c_d_o_m_secondary_token.dart';
import 'package:flutter_pcgen/src/rules/persistence/token/c_d_o_m_token.dart';
import 'package:flutter_pcgen/src/rules/persistence/token/deferred_token.dart';
import 'package:flutter_pcgen/src/rules/persistence/util/revision.dart';

/// Organises token implementations by the PCGen [Revision] for which they apply.
///
/// [TokenFamily.current] covers the running version; [TokenFamily.rev514]
/// provides backward-compatibility for data written against PCGen 5.14.
final class TokenFamily implements Comparable<TokenFamily> {
  // ---------------------------------------------------------------------------
  // Static constants
  // ---------------------------------------------------------------------------

  static final TokenFamily current =
      TokenFamily._(Revision(int.parse('7fffffff', radix: 16), 0, 0));

  static final TokenFamily rev514 =
      TokenFamily._(Revision(5, 14, -2147483648)); // Integer.MIN_VALUE

  // Static sorted map of all known families, keyed by Revision.
  static final SplayTreeMap<Revision, TokenFamily> _typeMap =
      SplayTreeMap<Revision, TokenFamily>()
        ..[current.rev] = current
        ..[rev514.rev] = rev514;

  // ---------------------------------------------------------------------------
  // Instance state
  // ---------------------------------------------------------------------------

  final Revision rev;

  /// Primary tokens: tokenClass → tokenName → token.
  final Map<Type, Map<String, CDOMToken<dynamic>>> _tokenMap = {};

  /// Secondary (sub) tokens: tokenClass → parentName → subName → token.
  final Map<Type, Map<String, Map<String, CDOMSecondaryToken<dynamic>>>>
      _subTokenMap = {};

  /// Prerequisite parser tokens keyed by lower-case kind string.
  final Map<String, PrerequisiteParserInterface> _preTokenMap = {};

  /// Deferred tokens run after the initial load pass.
  final List<DeferredToken<dynamic>> _deferredTokenList = [];

  TokenFamily._(this.rev);

  // ---------------------------------------------------------------------------
  // Factory / registry
  // ---------------------------------------------------------------------------

  static TokenFamily getConstant(int primary, int secondary, int tertiary) {
    final r = Revision(primary, secondary, tertiary);
    return _typeMap.putIfAbsent(r, () => TokenFamily._(r));
  }

  static void clearConstants() {
    _typeMap.clear();
    _typeMap[current.rev] = current;
    _typeMap[rev514.rev] = rev514;
  }

  static Iterable<TokenFamily> getAllConstants() =>
      UnmodifiableListView(_typeMap.values.toList());

  // ---------------------------------------------------------------------------
  // Primary token CRUD
  // ---------------------------------------------------------------------------

  CDOMToken<dynamic>? putToken(CDOMToken<dynamic> tok) {
    final map = _tokenMap.putIfAbsent(tok.getTokenClass(), () => {});
    final prev = map[tok.getTokenName()];
    map[tok.getTokenName()] = tok;
    return prev;
  }

  CDOMToken<dynamic>? getToken(Type cl, String name) =>
      _tokenMap[cl]?[name];

  Set<CDOMToken<dynamic>> getTokens(Type cl) =>
      Set.unmodifiable(_tokenMap[cl]?.values.toSet() ?? <CDOMToken<dynamic>>{});

  // ---------------------------------------------------------------------------
  // Secondary (sub) token CRUD
  // ---------------------------------------------------------------------------

  CDOMSecondaryToken<dynamic>? putSubToken(CDOMSecondaryToken<dynamic> tok) {
    final byParent = _subTokenMap.putIfAbsent(tok.getTokenClass(), () => {});
    final byName =
        byParent.putIfAbsent(tok.getParentToken().toLowerCase(), () => {});
    final prev = byName[tok.getTokenName().toLowerCase()];
    byName[tok.getTokenName().toLowerCase()] = tok;
    return prev;
  }

  CDOMSecondaryToken<dynamic>? getSubToken(Type cl, String token, String key) =>
      _subTokenMap[cl]?[token.toLowerCase()]?[key.toLowerCase()];

  Set<CDOMSecondaryToken<dynamic>> getSubTokens(Type cl, String token) =>
      Set.unmodifiable(
          _subTokenMap[cl]?[token.toLowerCase()]?.values.toSet() ??
              <CDOMSecondaryToken<dynamic>>{});

  // ---------------------------------------------------------------------------
  // Prerequisite tokens
  // ---------------------------------------------------------------------------

  void putPrerequisiteToken(PrerequisiteParserInterface token) {
    for (final kind in token.kindsHandled()) {
      _preTokenMap[kind.toLowerCase()] = token;
    }
  }

  PrerequisiteParserInterface? getPrerequisiteToken(String key) =>
      _preTokenMap[key.toLowerCase()];

  // ---------------------------------------------------------------------------
  // Deferred tokens
  // ---------------------------------------------------------------------------

  void addDeferredToken(DeferredToken<dynamic> newToken) =>
      _deferredTokenList.add(newToken);

  List<DeferredToken<dynamic>> getDeferredTokens() =>
      List.unmodifiable(_deferredTokenList);

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  void clearTokens() {
    _tokenMap.clear();
    _subTokenMap.clear();
    _deferredTokenList.clear();
    _preTokenMap.clear();
  }

  // ---------------------------------------------------------------------------
  // Comparable / Object
  // ---------------------------------------------------------------------------

  @override
  int compareTo(TokenFamily other) => rev.compareTo(other.rev);

  @override
  bool operator ==(Object other) =>
      other is TokenFamily && compareTo(other) == 0;

  @override
  int get hashCode => rev.hashCode;

  @override
  String toString() => 'Token Family: $rev';
}
