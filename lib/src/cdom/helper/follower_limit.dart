import '../../base/formula/formula.dart';
import '../list/companion_list.dart';
import '../reference/cdom_single_ref.dart';

// Represents an upper bound (as a Formula) on companions in a CompanionList.
class FollowerLimit {
  final CdomSingleRef<CompanionList> _ref;
  final Formula _formula;

  FollowerLimit(CdomSingleRef<CompanionList> clRef, Formula limit)
      : _ref = clRef,
        _formula = limit;

  CdomSingleRef<CompanionList> getCompanionList() => _ref;
  Formula getValue() => _formula;

  @override
  bool operator ==(Object other) {
    if (other is FollowerLimit) {
      return _ref == other._ref && _formula == other._formula;
    }
    return false;
  }

  @override
  int get hashCode => _ref.hashCode * 31 + _formula.hashCode;
}
