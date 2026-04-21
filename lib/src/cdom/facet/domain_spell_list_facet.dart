// Copyright (c) Thomas Parker, 2012.
//
// Translation of pcgen.cdom.facet.DomainSpellListFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/core/domain.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';
import 'model/domain_facet.dart';
import 'spell_list_facet.dart';

/// Tracks the Domain Spell Lists granted to a Player Character via Domain
/// selections.
class DomainSpellListFacet
    implements DataFacetChangeListener<CharID, Domain> {
  late SpellListFacet spellListFacet;
  late DomainFacet domainFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, Domain> dfce) {
    final list = dfce.getCDOMObject()
        .get(ObjectKey.getConstant('DOMAIN_SPELLLIST'));
    if (list != null) {
      spellListFacet.add(dfce.getCharID(), list, dfce.getCDOMObject());
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, Domain> dfce) {
    final list = dfce.getCDOMObject()
        .get(ObjectKey.getConstant('DOMAIN_SPELLLIST'));
    if (list != null) {
      spellListFacet.remove(dfce.getCharID(), list, dfce.getCDOMObject());
    }
  }
}
