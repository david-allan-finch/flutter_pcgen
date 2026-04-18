import '../../base/formula/formula.dart';
import '../reference/cdom_single_ref.dart';
import '../../core/pc_stat.dart';

// Represents a PCStat locked to a specific value (which may be a formula).
class StatLock {
  final CdomSingleRef<PCStat> _lockedStat;
  final Formula _lockValue;

  StatLock(CdomSingleRef<PCStat> stat, Formula formula)
      : _lockedStat = stat,
        _lockValue = formula;

  PCStat getLockedStat() => _lockedStat.get();
  String getLSTformat() => _lockedStat.getLSTformat(false);
  Formula getLockValue() => _lockValue;

  @override
  bool operator ==(Object other) {
    if (other is StatLock) {
      return _lockValue == other._lockValue && _lockedStat == other._lockedStat;
    }
    return false;
  }

  @override
  int get hashCode => _lockValue.hashCode;
}
