// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.EquipSetFacet

import '../enumeration/char_id.dart';
import '../../core/character/equip_set.dart';
import '../../core/equipment.dart';
import 'base/abstract_list_facet.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';

/// Tracks the [EquipSet]s for a Player Character.
class EquipSetFacet extends AbstractListFacet<CharID, EquipSet>
    implements DataFacetChangeListener<CharID, Equipment> {
  static const String _sep = '.';

  /// Removes [eSet] and all of its children from the PC's equipment sets.
  bool delEquipSet(CharID id, EquipSet eSet) {
    final componentSet = getCachedSet(id);
    if (componentSet == null) return false;

    bool found = false;
    final pid = eSet.getIdPath();

    componentSet.remove(eSet);

    final toRemove = <EquipSet>[];
    for (final es in componentSet) {
      final abParentId = es.getParentIdPath() + _sep;
      final abPid = pid + _sep;
      if (abParentId.startsWith(abPid)) {
        toRemove.add(es);
        found = true;
      }
    }
    componentSet.removeAll(toRemove);
    return found;
  }

  /// Replaces all instances of [oldItem] with [newItem] across all equipment sets.
  void updateEquipSetItem(CharID id, Equipment oldItem, Equipment newItem) {
    if (isEmpty(id)) return;
    for (final es in getSet(id)) {
      final eqI = es.getItem();
      if (eqI != null && oldItem == eqI) {
        es.setValue(newItem.getName());
        es.setItem(newItem);
      }
    }
  }

  /// Removes all EquipSets that contain [eq].
  void delEquipSetItem(CharID id, Equipment eq) {
    if (isEmpty(id)) return;
    final toRemove = <EquipSet>[];
    for (final es in getSet(id)) {
      final eqI = es.getItem();
      if (eqI != null && eq == eqI) {
        toRemove.add(es);
      }
    }
    for (final es in toRemove) {
      delEquipSet(id, es);
    }
  }

  /// Returns the [EquipSet] with the given [path], or null.
  EquipSet? getEquipSetByIdPath(CharID id, String path) {
    for (final eSet in getSet(id)) {
      if (eSet.getIdPath() == path) return eSet;
    }
    return null;
  }

  /// Returns the [EquipSet] with the given [name], or null.
  EquipSet? getEquipSetByName(CharID id, String name) {
    for (final eSet in getSet(id)) {
      if (eSet.getName() == name) return eSet;
    }
    return null;
  }

  /// Returns the count of items named [name] under [idPath].
  double getEquipSetCount(CharID id, String idPath, String name) {
    double count = 0;
    for (final eSet in getSet(id)) {
      final esID = eSet.getIdPath() + _sep;
      final abID = idPath + _sep;
      if (esID.startsWith(abID) && eSet.getValue() == name) {
        count += eSet.getQty();
      }
    }
    return count;
  }

  /// Returns the quantity of [eq] equipped in [set].
  double getEquippedQuantity(CharID id, EquipSet set, Equipment eq) {
    final rPath = set.getIdPath();
    for (final es in getSet(id)) {
      final esIdPath = es.getIdPath() + _sep;
      final rIdPath = rPath + _sep;
      if (!esIdPath.startsWith(rIdPath)) continue;
      if (eq.getName() == es.getValue()) return es.getQty();
    }
    return 0;
  }

  @override
  void dataAdded(DataFacetChangeEvent<CharID, Equipment> dfce) {
    // Intentionally ignored — EquipSets are managed directly.
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, Equipment> dfce) {
    delEquipSetItem(dfce.getCharID(), dfce.getCDOMObject());
  }
}
