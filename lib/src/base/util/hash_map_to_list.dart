import 'abstract_map_to_list.dart';

class HashMapToList<K, V> extends AbstractMapToList<K, V> {
  HashMapToList() : super({});

  @override
  Set<K> getEmptySet() => <K>{};
}
