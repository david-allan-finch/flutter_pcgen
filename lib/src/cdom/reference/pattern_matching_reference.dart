import '../base/cdom_reference.dart';
import '../base/loadable.dart';
import '../enumeration/grouping_state.dart';
import 'cdom_group_ref.dart';

// A CDOMReference that contains objects whose key starts with a given prefix
// pattern (ending in '%' in LST notation).
class PatternMatchingReference<T extends Loadable> extends CDOMReference<T> {
  final CDOMGroupRef<T> _all;
  final String _pattern; // prefix (without trailing %)

  PatternMatchingReference(CDOMGroupRef<T> startingGroup, String patternText)
      : _all = startingGroup,
        _pattern = _extractPrefix(patternText),
        super(patternText);

  static String _extractPrefix(String patternText) {
    if (!patternText.endsWith('%')) {
      throw ArgumentError(
          'Pattern for PatternMatchingReference must end with %');
    }
    return patternText.substring(0, patternText.length - 1);
  }

  @override
  bool contains(T item) =>
      _all.contains(item) && item.getKeyName().startsWith(_pattern);

  @override
  void addResolution(T item) {
    throw StateError('Cannot add resolution to PatternMatchingReference');
  }

  @override
  List<T> getContainedObjects() => _all
      .getContainedObjects()
      .where((obj) => obj.getKeyName().startsWith(_pattern))
      .toList();

  @override
  int getObjectCount() =>
      _all.getContainedObjects()
          .where((obj) => obj.getKeyName().startsWith(_pattern))
          .length;

  @override
  String getLSTformat([String? joinWith]) => getName();

  @override
  GroupingState getGroupingState() => GroupingState.any;

  @override
  String? getChoice() => null;

  @override
  Type getReferenceClass() => _all.getReferenceClass();

  @override
  String getReferenceDescription() =>
      '${_all.getReferenceDescription()} (Pattern $_pattern)';

  @override
  String getPersistentFormat() => _all.getPersistentFormat();

  @override
  bool operator ==(Object other) {
    if (other is PatternMatchingReference<T>) {
      return getReferenceClass() == other.getReferenceClass() &&
          _all == other._all &&
          _pattern == other._pattern;
    }
    return false;
  }

  @override
  int get hashCode => getReferenceClass().hashCode ^ _pattern.hashCode;
}
