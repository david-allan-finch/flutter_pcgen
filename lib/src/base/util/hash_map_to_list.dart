import 'package:flutter_pcgen/src/base/util/abstract_map_to_list.dart';

class HashMapToList<K, V> extends AbstractMapToList<K, V> {
  HashMapToList() : super({});

  @override
  Set<K> getEmptySet() => <K>{};
}
