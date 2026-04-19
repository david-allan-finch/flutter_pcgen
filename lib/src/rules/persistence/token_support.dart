// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.TokenSupport

import '../../rules/context/load_context.dart';
import 'token/c_d_o_m_primary_token.dart';
import 'token/c_d_o_m_secondary_token.dart';
import 'token/c_d_o_m_token.dart';
import 'token/complex_parse_result.dart';
import 'token/deferred_token.dart';
import 'token/parse_result.dart';
import 'token_library.dart';
import 'util/token_family.dart';
import 'util/token_family_iterator.dart';
import 'util/token_family_sub_iterator.dart';

/// Supports processing and unparsing of tokens for a given [LoadContext].
///
/// Translation of pcgen.rules.persistence.TokenSupport.
class TokenSupport {
  /// Local overrides stored in a dedicated TokenFamily slot (priority 0.0.0).
  final TokenFamily _localTokens = TokenFamily.getConstant(0, 0, 0);

  /// Cache: targetType → tokenName → list of matching tokens.
  final Map<Type, Map<String, List<CDOMToken<dynamic>>>> _tokenCache = {};

  /// Cache: targetType → parentName → subName → list of matching tokens.
  final Map<Type, Map<String, Map<String, List<CDOMToken<dynamic>>>>>
      _subTokenCache = {};

  // ---------------------------------------------------------------------------
  // Primary token processing
  // ---------------------------------------------------------------------------

  /// Processes a single token on [target].
  ///
  /// Looks up the token via [TokenLibrary] (and local overrides), calls
  /// [CDOMToken.parseToken], and returns true on first success.
  bool processToken<T>(
      LoadContext context, T target, String tokenName, String tokenValue) {
    // Check for a CDOMInterfaceToken first (overrides everything else).
    final interfaceToken = TokenLibrary.getInterfaceToken(tokenName);
    if (interfaceToken != null) {
      // TODO: check assignability in Dart equivalent
      // Fall through to class tokens for now if interface token cannot be used.
    }
    return _processClassTokens(context, target, tokenName, tokenValue);
  }

  bool _processClassTokens<T>(
      LoadContext context, T target, String tokenName, String tokenValue) {
    final cl = target.runtimeType;
    final tokenList = _getTokens(cl, tokenName);
    if (tokenList != null) {
      for (final token in tokenList) {
        ParseResult parse;
        try {
          parse = token.parseToken(context, target, tokenValue);
        } catch (e) {
          parse = ParseResultFail('Token processing failed: $e');
        }
        parse.addMessagesToLog(context.getSourceURI());
        if (parse.passed()) return true;
      }
    }
    if (tokenName.startsWith(' ')) {
      print('LST_ERROR: Illegal whitespace at start of token '
          "'$tokenName' '$tokenValue' for $cl in ${context.getSourceURI()}");
    } else {
      print('LST_ERROR: Illegal Token '
          "'$tokenName' '$tokenValue' for $cl in ${context.getSourceURI()}");
    }
    return false;
  }

  // ---------------------------------------------------------------------------
  // Sub-token processing
  // ---------------------------------------------------------------------------

  /// Processes a sub-token (e.g. CHOOSE sub-keys).
  ParseResult processSubToken<T>(
      LoadContext context, T cdo, String tokenName, String key, String value) {
    final cpr = ComplexParseResult();
    final cl = cdo.runtimeType;
    final tokenList = _getSubTokens(cl, tokenName, key);
    if (tokenList != null) {
      for (final token in tokenList) {
        final pr = token.parseToken(context, cdo, value);
        if (pr.passed()) return pr;
        cpr.copyMessages(pr);
        cpr.addErrorMessage('Failed in parsing subtoken: $key of $value');
      }
    }
    cpr.addErrorMessage(
        "Illegal $tokenName subtoken '$key' '$value' for $cl $cdo");
    return cpr;
  }

  // ---------------------------------------------------------------------------
  // Unparse
  // ---------------------------------------------------------------------------

  /// Unparses [loadable] back into its equivalent LST token strings.
  ///
  /// Returns null if no tokens produced output.
  List<String>? unparse<T>(LoadContext context, T loadable) {
    final set = <String>{};
    final cl = loadable.runtimeType;

    // Interface tokens.
    for (final interfaceToken in TokenLibrary.getInterfaceTokens()) {
      // TODO: check interface assignability
      final s = interfaceToken.unparse(context, loadable);
      if (s != null) {
        for (final str in s) {
          set.add('${interfaceToken.getTokenName()}:$str');
        }
      }
    }

    // Primary tokens via family iterator.
    final it = TokenFamilyIterator<T>(cl);
    while (it.moveNext()) {
      final token = it.current;
      final s = token.unparse(context, loadable);
      if (s != null) {
        for (final str in s) {
          set.add('${token.getTokenName()}:$str');
        }
      }
    }

    return set.isEmpty ? null : set.toList();
  }

  /// Unparses a sub-token group (e.g. all ABILITY sub-tokens).
  List<String>? unparseSubtoken<T>(
      LoadContext context, T cdo, String tokenName) {
    final separator = tokenName.startsWith('*') ? ':' : '|';
    final set = <String>{};
    final cl = cdo.runtimeType;

    final it = TokenFamilySubIterator<T>(cl, tokenName);
    while (it.moveNext()) {
      final token = it.current;
      final s = token.unparse(context, cdo);
      if (s != null) {
        for (final str in s) {
          set.add('${token.getTokenName()}$separator$str');
        }
      }
    }

    // Local tokens.
    final local = _localTokens.getSubTokens(cl, tokenName);
    for (final token in local) {
      final s = token.unparse(context, cdo);
      if (s != null) {
        for (final str in s) {
          set.add('${token.getTokenName()}$separator$str');
        }
      }
    }

    return set.isEmpty ? null : set.toList();
  }

  // ---------------------------------------------------------------------------
  // Deferred tokens
  // ---------------------------------------------------------------------------

  List<DeferredToken<dynamic>> getDeferredTokens() {
    return [
      ..._localTokens.getDeferredTokens(),
      ...TokenFamily.current.getDeferredTokens(),
    ];
  }

  // ---------------------------------------------------------------------------
  // Local token support
  // ---------------------------------------------------------------------------

  void loadLocalToken(dynamic token) {
    TokenLibrary.loadFamily(_localTokens, token);
  }

  // ---------------------------------------------------------------------------
  // Internal cache helpers
  // ---------------------------------------------------------------------------

  List<CDOMToken<dynamic>>? _getTokens(Type cl, String name) {
    final cached = _tokenCache[cl]?[name];
    if (cached != null) return cached;

    final list = <CDOMToken<dynamic>>[];
    final local = _localTokens.getToken(cl, name);
    if (local != null) list.add(local);
    list.addAll(TokenLibrary.getTokens(cl, name));

    if (list.isNotEmpty) {
      _tokenCache.putIfAbsent(cl, () => {})[name] = list;
    }
    return list.isEmpty ? null : list;
  }

  List<CDOMToken<dynamic>>? _getSubTokens(
      Type cl, String name, String subtoken) {
    final cached = _subTokenCache[cl]?[name]?[subtoken];
    if (cached != null) return cached;

    final list = <CDOMToken<dynamic>>[];
    final local = _localTokens.getSubToken(cl, name, subtoken);
    if (local != null) list.add(local);
    // TODO: iterate sub-token families via SubTokenIterator equivalent

    if (list.isNotEmpty) {
      _subTokenCache
          .putIfAbsent(cl, () => {})
          .putIfAbsent(name, () => {})[subtoken] = list;
    }
    return list.isEmpty ? null : list;
  }
}

