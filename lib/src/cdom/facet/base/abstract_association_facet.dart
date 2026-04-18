import '../../base/pcgen_identifier.dart';
import '../event/data_facet_change_event.dart';
import 'abstract_scope_facet.dart';

// Facet that stores a single association per source object per IDT.
abstract class AbstractAssociationFacet<IDT extends PCGenIdentifier, S, A>
    extends AbstractScopeFacet<IDT, S, A> {

  Map<S, A>? getCachedMap(IDT id) => getCache(id) as Map<S, A>?;

  Map<S, A> _getConstructingCachedMap(IDT id) {
    var map = getCachedMap(id);
    if (map == null) {
      map = getComponentMap();
      setCache(id, map);
    }
    return map;
  }

  Map<S, A> getComponentMap() => <S, A>{};

  A? getAssoc(IDT id, S obj) => getCachedMap(id)?[obj];

  void set(IDT id, S obj, A association) {
    final map = _getConstructingCachedMap(id);
    final old = map[obj];
    if (old != null) {
      fireScopeFacetChangeEvent(id, obj, old as dynamic, DataFacetChangeEvent.dataRemoved);
    }
    map[obj] = association;
    fireScopeFacetChangeEvent(id, obj, association as dynamic, DataFacetChangeEvent.dataAdded);
  }

  void removeAssoc(IDT id, S obj) {
    final map = getCachedMap(id);
    if (map == null) return;
    final old = map.remove(obj);
    if (old != null) {
      fireScopeFacetChangeEvent(id, obj, old as dynamic, DataFacetChangeEvent.dataRemoved);
    }
  }

  Map<S, A> removeAll(IDT id) {
    final map = removeCache(id) as Map<S, A>?;
    if (map == null) return {};
    for (final e in map.entries) {
      fireScopeFacetChangeEvent(id, e.key, e.value as dynamic, DataFacetChangeEvent.dataRemoved);
    }
    return map;
  }

  Set<S> getKeySet(IDT id) {
    final map = getCachedMap(id);
    if (map == null) return const {};
    return Set.unmodifiable(map.keys.toSet());
  }

  int getCount(IDT id) => getCachedMap(id)?.length ?? 0;

  bool isEmptyAssoc(IDT id) {
    final map = getCachedMap(id);
    return map == null || map.isEmpty;
  }

  bool containsAssoc(IDT id, S obj) =>
      getCachedMap(id)?.containsKey(obj) ?? false;

  @override
  void copyContents(IDT source, IDT destination) {
    final sourceMap = getCachedMap(source);
    if (sourceMap != null) {
      _getConstructingCachedMap(destination).addAll(sourceMap);
    }
  }
}
