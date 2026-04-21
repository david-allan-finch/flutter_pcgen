// Translation of pcgen.gui2.tabs.models.DeferredCharacterComboBoxModel

import 'character_combo_box_model.dart';

/// A CharacterComboBoxModel whose item list is populated lazily on first access.
class DeferredCharacterComboBoxModel<T> extends CharacterComboBoxModel<T> {
  bool _loaded = false;

  DeferredCharacterComboBoxModel({
    required super.selectedReader,
    required super.itemsReader,
    super.writer,
  });

  @override
  void install(dynamic character) {
    if (!_loaded) {
      _loaded = true;
      super.install(character);
    } else {
      // Re-read selected only
      final sel = items.isNotEmpty ? items.first : null;
      selected = sel;
    }
  }

  void reset() {
    _loaded = false;
  }
}
