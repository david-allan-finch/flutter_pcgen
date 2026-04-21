//
// Copyright (c) Thomas Parker, 2010.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.cdom.facet.base.AbstractCNASEnforcingFacet
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/helper/cn_ability_selection.dart';
import 'package:flutter_pcgen/src/cdom/helper/cn_ability_selection_utilities.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_data_facet.dart';

// Helper pairing a CNAbilitySelection with its source object.
class SourcedCNAS {
  final CNAbilitySelection cnas;
  final Object source;

  SourcedCNAS(this.cnas, this.source);

  @override
  String toString() => '$cnas (src: $source)';

  @override
  int get hashCode => source.hashCode ^ cnas.hashCode;

  @override
  bool operator ==(Object o) =>
      o is SourcedCNAS && cnas == o.cnas && source == o.source;
}

// Facet that enforces CNAS coexistence rules: conflicting abilities are queued
// behind their primary and only the primary is visible to listeners.
abstract class AbstractCNASEnforcingFacet
    extends AbstractDataFacet<CharID, CNAbilitySelection>
    implements DataFacetChangeListener<CharID, CNAbilitySelection> {

  List<List<SourcedCNAS>>? _getList(CharID id) =>
      getCache(id) as List<List<SourcedCNAS>>?;

  List<List<SourcedCNAS>> _getConstructingList(CharID id) {
    var list = _getList(id);
    if (list == null) {
      list = [];
      setCache(id, list);
    }
    return list;
  }

  bool isEmpty(CharID id) {
    final list = _getList(id);
    return list == null || list.isEmpty;
  }

  int getCount(CharID id) => _getList(id)?.length ?? 0;

  bool add(CharID id, CNAbilitySelection cnas, Object source) {
    final list = _getConstructingList(id);
    for (final slist in list) {
      final main = slist.first.cnas;
      if (!CNAbilitySelectionUtilities.canCoExist(main, cnas)) {
        slist.add(SourcedCNAS(cnas, source));
        return false;
      }
    }
    list.add([SourcedCNAS(cnas, source)]);
    fireDataFacetChangeEvent(id, cnas, DataFacetChangeEvent.dataAdded);
    return true;
  }

  bool removeCnas(CharID id, CNAbilitySelection cnas, Object source) {
    final list = _getList(id);
    if (list == null) return false;
    for (int i = 0; i < list.length; i++) {
      final array = list[i];
      for (int j = array.length - 1; j >= 0; j--) {
        final sc = array[j];
        if (cnas == sc.cnas && source == sc.source) {
          if (j == 0 && array.length == 1) {
            list.removeAt(i);
            fireDataFacetChangeEvent(id, cnas, DataFacetChangeEvent.dataRemoved);
            return true;
          } else {
            array.removeAt(j);
            final newPrimary = array.first.cnas;
            if (cnas != newPrimary && j == 0) {
              fireDataFacetChangeEvent(id, cnas, DataFacetChangeEvent.dataRemoved);
              fireDataFacetChangeEvent(id, newPrimary, DataFacetChangeEvent.dataAdded);
              return true;
            }
            return false;
          }
        }
      }
    }
    return false;
  }

  List<CNAbilitySelection> getSet(CharID id) {
    final list = _getList(id);
    if (list == null) return const [];
    return list.map((a) => a.first.cnas).toList();
  }

  @override
  void copyContents(CharID source, CharID copy) {
    final list = _getList(source);
    if (list != null) {
      final dest = _getConstructingList(copy);
      for (final orig in list) {
        dest.add(List.of(orig));
      }
    }
  }

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CNAbilitySelection> dfce) =>
      add(dfce.getCharID(), dfce.getCDOMObject(), dfce.getSource());

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CNAbilitySelection> dfce) =>
      removeCnas(dfce.getCharID(), dfce.getCDOMObject(), dfce.getSource());
}
