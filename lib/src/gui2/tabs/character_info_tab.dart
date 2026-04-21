// Translation of pcgen.gui2.tabs.CharacterInfoTab

import 'tab_title.dart';

/// Interface that must be implemented by all tabs displaying character information.
///
/// The goal is to separate UI models from UI components. Models are cached per
/// character so switching between characters is fast — new models are not
/// created each time a character is selected.
abstract interface class CharacterInfoTab {
  /// Create the models needed to display [character] on this tab.
  ///
  /// Implementations MUST NOT make any UI changes here; this method only
  /// constructs model objects.
  ModelMap createModels(dynamic character);

  /// Attach the models in [models] to the UI components of this tab.
  void restoreModels(ModelMap models);

  /// Detach models / listeners from UI components and save any dirty state
  /// back into [models].
  void storeModels(ModelMap models);

  /// Returns the [TabTitle] used by [InfoTabbedPane] to render the tab header.
  TabTitle getTabTitle();
}

/// A typed map keyed by [Type], used to store and retrieve per-character
/// UI model objects without boxing into raw [Object] maps.
class ModelMap {
  final Map<Type, dynamic> _map = {};

  T? get<T>(Type key) => _map[key] as T?;

  void put<T>(Type key, T value) {
    _map[key] = value;
  }

  bool containsKey(Type key) => _map.containsKey(key);

  void clear() => _map.clear();
}
