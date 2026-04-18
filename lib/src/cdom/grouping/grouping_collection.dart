// Represents a set of PCGenScoped objects that can be iterated via process().
abstract interface class GroupingCollection<T> {
  String getInstructions();
  void process(dynamic target, void Function(dynamic) consumer);
}
