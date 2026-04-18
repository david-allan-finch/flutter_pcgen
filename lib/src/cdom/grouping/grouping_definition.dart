import 'grouping_collection.dart';
import 'grouping_info.dart';

// Parser that converts a persistent grouping string into a GroupingCollection.
abstract interface class GroupingDefinition<T> {
  String getIdentification();
  Type getUsableLocation();
  GroupingCollection<T> process(dynamic context, GroupingInfo<T> info);
  bool requiresDirect();
}
