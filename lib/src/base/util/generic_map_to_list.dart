import 'package:flutter_pcgen/src/base/util/abstract_map_to_list.dart';

// A MapToList backed by a custom map type.
class GenericMapToList<K, V> extends AbstractMapToList<K, V> {
  GenericMapToList() : super({});
  GenericMapToList.withMap(Map<K, List<V>> map) : super(map);

  @override
  Set<K> getEmptySet() => <K>{};
}
