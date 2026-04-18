// Translation of pcgen.output.publish.OutputDB

import '../base/model_factory.dart';
import '../base/mode_model_factory.dart';
import '../factory/item_model_factory.dart';
import '../factory/set_model_factory.dart';
import '../factory/channel_factory.dart';
import '../model/boolean_option_model.dart';

/// OutputDB is the output database for building the data map provided to
/// the template engine during character sheet export.
final class OutputDB {
  OutputDB._();

  /// Map of (k1, k2) → ModelFactory for PC-dependent output items.
  static final Map<String, Map<String, ModelFactory>> _outModels = {};

  /// Map of name → model for global (non-PC) items.
  static final Map<String, dynamic> _globalModels = {};

  /// Map of name → ModeModelFactory for game-mode items.
  static final Map<String, ModeModelFactory> _modeModels = {};

  /// Registers a ModelFactory under the given dot-separated name.
  ///
  /// The name may contain zero or one period (e.g. "stat" or "stat.str").
  static void registerModelFactory(String name, ModelFactory modelFactory) {
    final parts = name.split('.');
    if (parts.isEmpty || parts.length > 2) {
      throw ArgumentError('Name must have 0 or 1 period: $name');
    }
    final k1 = parts[0];
    final k2 = parts.length == 1 ? '' : parts[1];
    _outModels.putIfAbsent(k1, () => {})[k2] = modelFactory;
  }

  /// Registers an ItemFacet under the given name.
  static void registerItem(String name, dynamic facet) {
    registerModelFactory(name, ItemModelFactory(facet));
  }

  /// Registers a SetFacet under the given name.
  static void registerSet(String name, dynamic facet) {
    registerModelFactory(name, SetModelFactory(facet));
  }

  /// Registers a CControl channel under the given name.
  static void registerChannel(String name, dynamic control) {
    registerModelFactory(name, ChannelFactory(control));
  }

  /// Builds the full data model map for a given CharID.
  static Map<String, Object> buildDataModel(String charId) {
    final input = <String, Object>{};
    for (final k1 in _outModels.keys) {
      for (final entry in _outModels[k1]!.entries) {
        final k2 = entry.key;
        final model = entry.value.generate(charId);
        if (model == null) continue;
        if (k2.isEmpty) {
          input[k1] = model;
        } else {
          input.putIfAbsent(k1, () => <String, dynamic>{});
          (input[k1] as Map<String, dynamic>)[k2] = model;
        }
      }
    }
    return input;
  }

  /// Builds the game-mode data model map.
  static Map<String, Object> buildModeDataModel(dynamic mode) {
    final input = <String, Object>{};
    for (final entry in _modeModels.entries) {
      final model = entry.value.generate(mode);
      if (model != null) input[entry.key] = model;
    }
    return input;
  }

  /// Registers a ModeModelFactory under the given name.
  static void registerMode(String name, ModeModelFactory factory) {
    if (name.contains('.')) {
      throw ArgumentError('Mode name may not contain a dot: $name');
    }
    if (_modeModels.containsKey(name)) {
      throw UnsupportedError(
          'Cannot have two Mode Models using the same name: $name');
    }
    _modeModels[name] = factory;
  }

  /// Returns an iterable for the portion of the data model identified by keys.
  static Iterable? getIterable(String charId, List<String> keys) {
    final k1 = keys[0];
    final k2 = keys.length > 1 ? keys[1] : '';
    final factory = _outModels[k1]?[k2];
    if (factory == null) return null;
    final model = factory.generate(charId);
    if (model is Iterable) return model;
    return null;
  }

  /// Returns true if the given interpolation name is registered.
  static bool isLegal(String interpolation) =>
      _outModels.containsKey(interpolation);

  /// Resets the database (use when reloading sources or in tests).
  static void reset() {
    _outModels.clear();
    _globalModels.clear();
    _modeModels.clear();
  }

  /// Returns a copy of the global models map.
  static Map<String, dynamic> getGlobal() => Map.of(_globalModels);

  /// Registers a boolean preference in the global models.
  static void registerBooleanPreference(String pref, bool defaultValue) {
    if (pref.isEmpty) {
      throw ArgumentError('Preference Name may not be null or empty: $pref');
    }
    addGlobalModel(pref, BooleanOptionModel(pref, defaultValue));
  }

  /// Directly adds a model to the global models.
  static void addGlobalModel(String name, dynamic model) {
    if (_globalModels.containsKey(name)) {
      throw UnsupportedError(
          'Cannot have two Global Output Models using the same name: $name');
    }
    _globalModels[name] = model;
  }
}
