// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.TokenLibrary

import 'dart:collection';

import '../../persistence/lst/prereq/prerequisite_parser_interface.dart';
import 'token/c_d_o_m_compatibility_token.dart';
import 'token/c_d_o_m_interface_token.dart';
import 'token/c_d_o_m_primary_token.dart';
import 'token/c_d_o_m_secondary_token.dart';
import 'token/c_d_o_m_token.dart';
import 'token/deferred_token.dart';
import 'token/modifier_factory.dart';
import 'token/post_deferred_token.dart';
import 'token/post_validation_token.dart';
import 'token/primitive_token.dart';
import 'token/qualifier_token.dart';
import 'util/token_family.dart';

/// Static registry for all token types known to the PCGen rules engine.
///
/// Translation of pcgen.rules.persistence.TokenLibrary.
/// In Dart there is no class-literal syntax, so [Type] objects are used
/// everywhere Java would use [Class<?>].
final class TokenLibrary {
  // ---------------------------------------------------------------------------
  // Static registries
  // ---------------------------------------------------------------------------

  /// Sorted map from priority → list of post-deferred tokens.
  static final SplayTreeMap<int, List<PostDeferredToken<dynamic>>>
      _postDeferredTokens = SplayTreeMap();

  /// Sorted map from priority → list of post-validation tokens.
  static final SplayTreeMap<int, List<PostValidationToken<dynamic>>>
      _postValidationTokens = SplayTreeMap();

  /// Qualifier tokens: targetType → tokenName → token class factory.
  static final Map<Type, Map<String, QualifierToken<dynamic> Function()>>
      _qualifierMap = {};

  /// Primitive tokens: referenceType → tokenName → token class factory.
  static final Map<Type, Map<String, PrimitiveToken<dynamic> Function()>>
      _primitiveMap = {};

  /// Modifier factories: variableType → name → factory.
  static final Map<Type, Map<String, ModifierFactory<dynamic>>> _modifierMap =
      {};

  /// Interface tokens keyed by token name.
  static final Map<String, CDOMInterfaceToken<dynamic, dynamic>> _ifTokenMap =
      {};

  /// All known token families, kept sorted.
  static final SplayTreeMap<TokenFamily, TokenFamily> _tokenFamilies =
      SplayTreeMap((a, b) => a.compareTo(b));

  /// Bonus-class registry: bonus name → bonus type identifier string.
  static final Map<String, String> _bonusTagMap = {};

  static TokenLibrary? _instance;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  TokenLibrary._();

  static TokenLibrary getInstance() => _instance ??= TokenLibrary._();

  /// Resets the registry to its initial state (both standard families).
  static void reset() {
    _postDeferredTokens.clear();
    _qualifierMap.clear();
    _primitiveMap.clear();
    _modifierMap.clear();
    _ifTokenMap.clear();
    _bonusTagMap.clear();
    _tokenFamilies.clear();
    TokenFamily.current.clearTokens();
    _tokenFamilies[TokenFamily.current] = TokenFamily.current;
    TokenFamily.rev514.clearTokens();
    _tokenFamilies[TokenFamily.rev514] = TokenFamily.rev514;
  }

  // ---------------------------------------------------------------------------
  // Token registration
  // ---------------------------------------------------------------------------

  /// Registers [token] into the library, dispatching to the appropriate maps.
  static void addToTokenMap(dynamic token) {
    if (token is PostDeferredToken) {
      _postDeferredTokens
          .putIfAbsent(token.getPriority(), () => [])
          .add(token as PostDeferredToken<dynamic>);
    }
    if (token is PostValidationToken) {
      _postValidationTokens
          .putIfAbsent(token.getPriority(), () => [])
          .add(token as PostValidationToken<dynamic>);
    }
    if (token is CDOMCompatibilityToken) {
      final tok = token as CDOMCompatibilityToken<dynamic>;
      final fam = TokenFamily.getConstant(
          tok.compatibilityLevel(), tok.compatibilitySubLevel(),
          tok.compatibilityPriority());
      fam.putToken(tok);
      _tokenFamilies[fam] = fam;
    }
    if (token is CDOMInterfaceToken) {
      final tok = token as CDOMInterfaceToken<dynamic, dynamic>;
      _ifTokenMap[tok.getTokenName()] = tok;
    }
    loadFamily(TokenFamily.current, token);
  }

  /// Loads [token] into the given [family].
  static void loadFamily(TokenFamily family, dynamic token) {
    if (token is DeferredToken) {
      family.addDeferredToken(token as DeferredToken<dynamic>);
    }
    if (token is CDOMPrimaryToken) {
      family.putToken(token as CDOMPrimaryToken<dynamic>);
    }
    if (token is CDOMSecondaryToken) {
      family.putSubToken(token as CDOMSecondaryToken<dynamic>);
    }
    if (token is PrerequisiteParserInterface) {
      family.putPrerequisiteToken(token);
    }
  }

  // ---------------------------------------------------------------------------
  // Token lookup
  // ---------------------------------------------------------------------------

  /// Returns the first [CDOMToken] for the given [cl] and [name], searching
  /// from newest to oldest token family.
  static CDOMToken<dynamic>? getToken(Type cl, String name) {
    for (final fam in _tokenFamilies.keys.toList().reversed) {
      final tok = fam.getToken(cl, name);
      if (tok != null) return tok;
    }
    return null;
  }

  /// Returns all [CDOMToken] objects for [cl] / [name] across all families.
  static List<CDOMToken<dynamic>> getTokens(Type cl, String name) {
    final result = <CDOMToken<dynamic>>[];
    for (final fam in _tokenFamilies.keys) {
      final tok = fam.getToken(cl, name);
      if (tok != null) result.add(tok);
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Interface token access
  // ---------------------------------------------------------------------------

  static CDOMInterfaceToken<dynamic, dynamic>? getInterfaceToken(String name) =>
      _ifTokenMap[name];

  static Iterable<CDOMInterfaceToken<dynamic, dynamic>>
      getInterfaceTokens() => _ifTokenMap.values;

  // ---------------------------------------------------------------------------
  // Qualifier / Primitive token maps
  // ---------------------------------------------------------------------------

  /// Registers [token] in the qualifier map.
  ///
  /// [referenceClass] and [tokenName] identify where to register; they mirror
  /// QualifierToken.getReferenceClass() and LstToken.getTokenName() in Java.
  static void addToQualifierMap(
      Type referenceClass, String tokenName, QualifierToken<dynamic> Function() factory) {
    _qualifierMap.putIfAbsent(referenceClass, () => {})[tokenName] = factory;
  }

  static QualifierToken<dynamic>? getQualifier(Type cl, String name) =>
      _qualifierMap[cl]?[name]?.call();

  /// Registers [token] in the primitive map for the given [referenceClass].
  ///
  /// The [referenceClass] is the type of objects the primitive selects
  /// (mirrors Java's PrimitiveToken.getReferenceClass()).
  static void addToPrimitiveMap(
      Type referenceClass, String tokenName, PrimitiveToken<dynamic> Function() factory) {
    _primitiveMap.putIfAbsent(referenceClass, () => {})[tokenName] = factory;
  }

  static PrimitiveToken<dynamic>? getPrimitive(Type cl, String name) =>
      _primitiveMap[cl]?[name]?.call();

  // ---------------------------------------------------------------------------
  // Modifier factory map
  // ---------------------------------------------------------------------------

  static void addToModifierMap(ModifierFactory<dynamic> factory) {
    _modifierMap
        .putIfAbsent(factory.getVariableFormat(), () => {})[factory.getIdentification()] =
        factory;
  }

  static ModifierFactory<dynamic>? getModifier(Type cl, String name) =>
      _modifierMap[cl]?[name];

  // ---------------------------------------------------------------------------
  // Post-deferred / Post-validation token access
  // ---------------------------------------------------------------------------

  static List<PostDeferredToken<dynamic>> getPostDeferredTokens() {
    final result = <PostDeferredToken<dynamic>>[];
    for (final list in _postDeferredTokens.values) {
      result.addAll(list);
    }
    return result;
  }

  static List<PostValidationToken<dynamic>> getPostValidationTokens() {
    final result = <PostValidationToken<dynamic>>[];
    for (final list in _postValidationTokens.values) {
      result.addAll(list);
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Bonus class registry
  // ---------------------------------------------------------------------------

  /// Registers a bonus tag name, mapping it to [bonusTypeKey].
  static bool addBonusClass(String bonusHandled, String bonusTypeKey) {
    _bonusTagMap[bonusHandled] = bonusTypeKey;
    return true;
  }

  /// Returns the bonus type key for the given [bonusName], or null.
  static String? getBonus(String bonusName) => _bonusTagMap[bonusName];

  // ---------------------------------------------------------------------------
  // PluginLoader integration
  // ---------------------------------------------------------------------------

  /// Called by the plugin loader infrastructure with a token instance.
  ///
  /// In Dart we receive an already-constructed [token] instead of a [Type].
  /// Qualifier and Primitive tokens must be registered via [addToQualifierMap]
  /// / [addToPrimitiveMap] directly, as those require explicit type/name args
  /// that can't be inferred without additional metadata.
  void loadPlugin(dynamic token) {
    // TODO: distinguish BonusObj-equivalent types when ported.
    addToTokenMap(token);
    if (token is ModifierFactory) {
      addToModifierMap(token as ModifierFactory<dynamic>);
    }
  }

  List<Type> getPluginClasses() => const [];
}
