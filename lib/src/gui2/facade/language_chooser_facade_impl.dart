// Translation of pcgen.gui2.facade.LanguageChooserFacadeImpl

import 'general_chooser_facade_base.dart';

/// Chooser facade for selecting languages for a character.
class LanguageChooserFacadeImpl extends GeneralChooserFacadeBase<String> {
  final dynamic _character;

  LanguageChooserFacadeImpl(this._character, List<String> available, int maxSelections)
      : super(
          name: 'Choose Languages',
          available: available,
          selected: _extractSelected(_character),
          maxSelections: maxSelections,
        );

  static List<String> _extractSelected(dynamic character) {
    if (character == null) return [];
    if (character is Map) {
      final langs = character['languages'];
      if (langs is List) return langs.cast<String>();
    }
    return [];
  }

  @override
  void commit() {
    // Write selected languages back to character
    if (_character is Map) {
      _character['languages'] = List.of(
        Iterable.generate(getSelectedList().getSize(),
            (i) => getSelectedList().getElementAt(i) as String),
      );
    }
    super.commit();
  }
}
