// Translation of pcgen.gui2.converter.TokenConverter

import 'default_token_processor.dart';
import 'event/token_process_event.dart';
import 'event/token_processor_plugin.dart';

/// Static registry and dispatcher for [TokenProcessorPlugin] instances.
/// Plugins are registered with [addToTokenMap] and looked up per
/// (class, token-key) pair when [process] is called.
class TokenConverter {
  TokenConverter._();

  /// Primary map: class type → token key → single plugin.
  static final Map<Type, Map<String, TokenProcessorPlugin>> _map = {};

  /// Cache indicating whether a (class, key) pair has been fully resolved
  /// through the class hierarchy.
  static final Map<Type, Set<String>> _cached = {};

  /// Resolved list cache: class type → token key → ordered list of plugins.
  static final Map<Type, Map<String, List<TokenProcessorPlugin>>> _tokenCache =
      {};

  static final DefaultTokenProcessor _defaultProc = DefaultTokenProcessor();

  /// Registers [tpp] in the token map.  Logs an error if a plugin already
  /// exists for the same (class, token) combination.
  static void addToTokenMap(TokenProcessorPlugin tpp) {
    final byClass = _map.putIfAbsent(tpp.getProcessedClass(), () => {});
    if (byClass.containsKey(tpp.getProcessedToken())) {
      print(
        'ERROR: More than one Conversion token for '
        '${tpp.getProcessedClass()} ${tpp.getProcessedToken()} found',
      );
    }
    byClass[tpp.getProcessedToken()] = tpp;
  }

  /// Processes [tpe] using any registered plugins for the object's runtime
  /// type, falling back to [DefaultTokenProcessor] if none consume the event.
  /// Returns null on success, or an error message string.
  static String? process(TokenProcessEvent tpe) {
    final cl = tpe.getPrimary().runtimeType;
    final key = tpe.getKey();

    _ensureCategoryExists(tpe);

    final tokens = getTokens(cl, key);
    final error = StringBuffer();
    try {
      if (tokens != null) {
        for (final converter in tokens) {
          final err = converter.process(tpe);
          if (err != null) error.write(err);
          if (tpe.isConsumed()) break;
        }
      }
      if (!tpe.isConsumed()) {
        final err = _defaultProc.process(tpe);
        if (err != null) error.write(err);
      }
    } catch (ex) {
      print(
        'ERROR: Parse of ${tpe.getKey()}:${tpe.getValue()} failed: $ex',
      );
    }
    return tpe.isConsumed() ? null : error.toString();
  }

  /// Ensures an AbilityCategory CDOMObject exists when the token is ABILITY.
  static void _ensureCategoryExists(TokenProcessEvent tpe) {
    if (tpe.getKey() != 'ABILITY') return;
    final value = tpe.getValue();
    if (value == null) return;
    final pipeIndex = value.indexOf('|');
    final cat = pipeIndex >= 0 ? value.substring(0, pipeIndex) : value;
    final refCtx = tpe.getContext().getReferenceContext();
    final existing =
        refCtx.silentlyGetConstructedCDOMObject('AbilityCategory', cat);
    if (existing == null) {
      refCtx.constructCDOMObject('AbilityCategory', cat);
    }
  }

  /// Returns the ordered list of plugins for ([cl], [name]), resolving the
  /// class hierarchy lazily and caching the result.
  static List<TokenProcessorPlugin>? getTokens(Type cl, String name) {
    final cached = _cached[cl]?.contains(name) ?? false;
    if (!cached) {
      // Walk the type hierarchy — Dart doesn't expose a superclass chain at
      // runtime, so we iterate the registered keys that match [cl] directly.
      // Sub-class resolution is best-effort; plugins should be registered for
      // the concrete type they handle.
      Type? current = cl;
      while (current != null) {
        final plugin = _map[current]?[name];
        if (plugin != null) {
          _tokenCache.putIfAbsent(cl, () => {}).putIfAbsent(name, () => []).add(plugin);
        }
        // Dart reflection limitation: we cannot walk super-types generically,
        // so stop after the first level unless the map has explicit entries.
        break;
      }
      _cached.putIfAbsent(cl, () => {}).add(name);
    }
    return _tokenCache[cl]?[name];
  }

  /// Clears all registered plugin data (used between test runs).
  static void clear() {
    _map.clear();
    _tokenCache.clear();
    _cached.clear();
  }
}
