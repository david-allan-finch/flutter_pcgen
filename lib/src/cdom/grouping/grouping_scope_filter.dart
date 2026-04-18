import 'grouping_collection.dart';

// Decorates a GroupingCollection to filter by PCGenScope name.
class GroupingScopeFilter<T> implements GroupingCollection<T> {
  final GroupingCollection<T> _underlying;
  final String _scopeName;

  GroupingScopeFilter(GroupingCollection<T> underlying, String scopeName)
      : _underlying = underlying,
        _scopeName = scopeName;

  @override
  String getInstructions() => _underlying.getInstructions();

  @override
  void process(dynamic target, void Function(dynamic) consumer) {
    // Only pass to underlying if the target's scope name matches
    final scope = target.getLocalScopeName?.call();
    if (scope == null || scope == _scopeName) {
      _underlying.process(target, consumer);
    }
  }
}
