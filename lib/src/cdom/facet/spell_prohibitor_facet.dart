// Copyright (c) Thomas Parker, 2012.
//
// Translation of pcgen.cdom.facet.SpellProhibitorFacet

import '../enumeration/char_id.dart';
import '../enumeration/list_key.dart';
import '../../core/pc_class.dart';
import '../../core/spell_prohibitor.dart';
import 'base/abstract_scope_facet.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';
import 'model/class_facet.dart';

/// Tracks [SpellProhibitor] objects for each [PCClass] on a Player Character.
class SpellProhibitorFacet extends AbstractScopeFacet<CharID, PCClass, SpellProhibitor>
    implements DataFacetChangeListener<CharID, PCClass> {
  late ClassFacet classFacet;

  void init() {
    classFacet.addDataFacetChangeListener(this);
  }

  @override
  void dataAdded(DataFacetChangeEvent<CharID, PCClass> dfce) {
    final pcc = dfce.getCDOMObject();
    final id = dfce.getCharID();
    final source = dfce.getSource();
    for (final prohibit in pcc.getSafeListFor(
        ListKey.getConstant<SpellProhibitor>('PROHIBITED_SPELLS'))) {
      add(id, pcc, prohibit, source);
    }
    for (final prohibit in pcc.getSafeListFor(
        ListKey.getConstant<SpellProhibitor>('SPELL_PROHIBITOR'))) {
      add(id, pcc, prohibit, source);
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, PCClass> dfce) {
    removeAllFromSource(dfce.getCharID(), dfce.getCDOMObject());
  }
}
