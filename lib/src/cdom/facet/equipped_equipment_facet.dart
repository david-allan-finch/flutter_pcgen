// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.EquippedEquipmentFacet

import '../enumeration/char_id.dart';
import '../../core/equipment.dart';
import 'base/abstract_data_facet.dart';
import 'equipment_facet.dart';
import 'event/data_facet_change_event.dart';

/// Tracks the Equipment that is currently Equipped by a Player Character.
///
/// Call [reset] to refresh the equipped set when the PC's equipment state
/// changes.
class EquippedEquipmentFacet extends AbstractDataFacet<CharID, Equipment> {
  late EquipmentFacet equipmentFacet;

  /// Refreshes the equipped equipment set for the Player Character identified
  /// by [id], firing appropriate add/remove events for changes.
  void reset(CharID id) {
    final oldEquipped = removeCache(id) as Set<Equipment>?;
    final currentEquipment = equipmentFacet.getSet(id).toSet();
    final newEquipped = <Equipment>{};
    setCache(id, newEquipped);

    if (oldEquipped != null) {
      for (final e in oldEquipped) {
        if (!currentEquipment.contains(e)) {
          fireDataFacetChangeEvent(id, e, DataFacetChangeEvent.dataRemoved);
        }
      }
    }

    for (final e in currentEquipment) {
      if (e.isEquipped()) {
        newEquipped.add(e);
        if (oldEquipped == null || !oldEquipped.contains(e)) {
          fireDataFacetChangeEvent(id, e, DataFacetChangeEvent.dataAdded);
        }
      } else {
        if (oldEquipped != null && oldEquipped.contains(e)) {
          fireDataFacetChangeEvent(id, e, DataFacetChangeEvent.dataRemoved);
        }
      }
    }
  }

  /// Returns an unmodifiable copy of the equipped equipment set for [id].
  Set<Equipment> getSet(CharID id) {
    final set = getCache(id) as Set<Equipment>?;
    if (set == null) return const {};
    return Set.unmodifiable(set);
  }

  /// Returns the count of equipped items for [id].
  int getCount(CharID id) {
    final set = getCache(id) as Set<Equipment>?;
    return set?.length ?? 0;
  }

  /// Removes all equipped equipment data for [id].
  void removeAll(CharID id) => removeCache(id);

  @override
  void copyContents(CharID source, CharID copy) {
    final set = getCache(source) as Set<Equipment>?;
    if (set != null) {
      setCache(copy, Set<Equipment>.of(set));
    }
  }
}
