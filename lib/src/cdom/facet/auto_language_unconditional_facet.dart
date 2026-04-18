// Copyright (c) Thomas Parker, 2014.
//
// Translation of pcgen.cdom.facet.AutoLanguageUnconditionalFacet

import '../enumeration/char_id.dart';
import '../../core/language.dart';
import 'base/abstract_sourced_list_facet.dart';
import 'model/language_facet.dart';

/// Tracks Languages granted unconditionally via AUTO:LANG (no prerequisites).
class AutoLanguageUnconditionalFacet
    extends AbstractSourcedListFacet<CharID, Language> {
  late LanguageFacet languageFacet;

  void init() {
    addDataFacetChangeListener(languageFacet);
  }
}
