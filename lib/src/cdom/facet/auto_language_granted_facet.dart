// Copyright (c) Thomas Parker, 2013.
//
// Translation of pcgen.cdom.facet.AutoLanguageGrantedFacet

import '../enumeration/char_id.dart';
import '../../core/language.dart';
import 'auto_language_facet.dart';
import 'base/abstract_sourced_list_facet.dart';
import 'model/language_facet.dart';

/// Tracks Languages that have passed their AUTO:LANG prerequisites and are
/// actively granted to the Player Character.
class AutoLanguageGrantedFacet
    extends AbstractSourcedListFacet<CharID, Language> {
  late AutoLanguageFacet autoLanguageFacet;
  late LanguageFacet languageFacet;

  /// Syncs this facet with the currently qualified AUTO:LANG languages.
  /// Returns true if any additions or removals occurred.
  bool update(CharID id) {
    final current = getSet(id);
    final qualified = autoLanguageFacet.getAutoLanguage(id);
    final toRemove = current.toList()
      ..removeWhere(qualified.contains);
    final toAdd = qualified.toList()
      ..removeWhere(current.contains);
    for (final lang in toRemove) {
      remove(id, lang, autoLanguageFacet);
    }
    for (final lang in toAdd) {
      add(id, lang, autoLanguageFacet);
    }
    return toRemove.isNotEmpty || toAdd.isNotEmpty;
  }

  void init() {
    addDataFacetChangeListener(languageFacet);
  }
}
