// Copyright (c) Thomas Parker, 2014.
//
// Translation of pcgen.cdom.facet.AutoLanguageUnconditionalFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/core/language.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_sourced_list_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/language_facet.dart';

/// Tracks Languages granted unconditionally via AUTO:LANG (no prerequisites).
class AutoLanguageUnconditionalFacet
    extends AbstractSourcedListFacet<CharID, Language> {
  late LanguageFacet languageFacet;

  void init() {
    addDataFacetChangeListener(languageFacet);
  }
}
