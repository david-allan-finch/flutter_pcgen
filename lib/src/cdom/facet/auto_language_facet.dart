// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.AutoLanguageFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/core/language.dart';
import 'package:flutter_pcgen/src/core/qualified_object.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_qualified_list_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/auto_language_unconditional_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';

/// Tracks Languages granted via AUTO:LANG and LANGAUTO tokens that have
/// prerequisites (unconditional grants go to [AutoLanguageUnconditionalFacet]).
class AutoLanguageFacet
    extends AbstractQualifiedListFacet<QualifiedObject<CDOMReference<Language>>>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late AutoLanguageUnconditionalFacet autoLanguageUnconditionalFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final id = dfce.getCharID();
    // LANGAUTO
    final langAutoList = cdo.getSafeListFor(
        ListKey.getConstant<QualifiedObject<CDOMReference<Language>>>('AUTO_LANGUAGES'));
    _separateAll(id, langAutoList, cdo);
    // AUTO:LANG
    final autoLangList = cdo.getSafeListFor(
        ListKey.getConstant<QualifiedObject<CDOMReference<Language>>>('AUTO_LANGUAGE'));
    _separateAll(id, autoLangList, cdo);
  }

  void _separateAll(CharID id,
      List<QualifiedObject<CDOMReference<Language>>> list, CDOMObject cdo) {
    for (final qRef in list) {
      if (qRef.hasPrerequisites()) {
        add(id, qRef, cdo);
      } else {
        autoLanguageUnconditionalFacet.addAll(
            id, qRef.getRawObject().getContainedObjects(), cdo);
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final id = dfce.getCharID();
    final cdo = dfce.getCDOMObject();
    removeAllFromSource(id, cdo);
    autoLanguageUnconditionalFacet.removeAllFromSource(id, cdo);
  }

  /// Returns Languages from all qualifying AUTO:LANG grants.
  List<Language> getAutoLanguage(CharID id) {
    final list = <Language>[];
    for (final qo in getQualifiedSet(id)) {
      list.addAll(qo.getRawObject().getContainedObjects());
    }
    return list;
  }
}
