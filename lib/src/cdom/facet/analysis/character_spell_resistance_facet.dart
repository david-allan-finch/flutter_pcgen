// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.analysis.CharacterSpellResistanceFacet

import '../../base/cdom_object.dart';
import '../../enumeration/char_id.dart';
import '../../enumeration/object_key.dart';
import '../base/abstract_sourced_list_facet.dart';
import '../cdom_object_consolidation_facet.dart';
import '../event/data_facet_change_event.dart';
import '../event/data_facet_change_listener.dart';
import '../formula_resolving_facet.dart';

/// Tracks SpellResistance Formulas granted to a Player Character.
class CharacterSpellResistanceFacet extends AbstractSourcedListFacet<CharID, dynamic>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late FormulaResolvingFacet formulaResolvingFacet;
  late CDOMObjectConsolidationFacet consolidationFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final sr = cdo.get(ObjectKey.getConstant<dynamic>('SR'));
    if (sr != null) {
      add(dfce.getCharID(), sr.getReduction(), cdo);
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    removeAll(dfce.getCharID(), dfce.getCDOMObject());
  }

  /// Returns the Spell Resistance for the Player Character — the highest resolved value.
  int getSR(CharID id) {
    final componentMap = getCachedMap(id);
    int sr = 0;
    if (componentMap != null) {
      for (final entry in componentMap.entries) {
        final formula = entry.key;
        for (final source in entry.value) {
          final sourceString = (source is CDOMObject) ? source.getQualifiedKey() : '';
          final val = formulaResolvingFacet.resolve(id, formula, sourceString).toInt();
          if (val > sr) sr = val;
        }
      }
    }
    return sr;
  }

  void init() {
    consolidationFacet.addDataFacetChangeListener(this);
  }
}
