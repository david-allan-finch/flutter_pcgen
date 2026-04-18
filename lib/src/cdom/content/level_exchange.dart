import '../base/concrete_prereq_object.dart';
import '../reference/cdom_single_ref.dart';
import '../../core/pc_class.dart';

// Stores the constraints for a class level exchange.
class LevelExchange extends ConcretePrereqObject {
  final CdomSingleRef<PCClass> _exchangeClass;
  final int _minDonatingLevel;
  final int _maxDonatedLevels;
  final int _donatingLowerLevelBound;

  LevelExchange(CdomSingleRef<PCClass> pcc, int minDonatingLvl, int maxDonated, int donatingLowerBound)
      : _exchangeClass = pcc,
        _minDonatingLevel = minDonatingLvl,
        _maxDonatedLevels = maxDonated,
        _donatingLowerLevelBound = donatingLowerBound {
    if (minDonatingLvl <= 0) {
      throw ArgumentError('Error: Min Donating Level <= 0: Cannot Allow Donations to produce negative levels');
    }
    if (maxDonated <= 0) {
      throw ArgumentError('Error: Max Donated Levels <= 0: Cannot Allow Donations to produce negative levels');
    }
    if (donatingLowerBound < 0) {
      throw ArgumentError('Error: Max Remaining Levels < 0: Cannot Allow Donations to produce negative levels');
    }
    if (minDonatingLvl - maxDonated > donatingLowerBound) {
      throw ArgumentError('Error: Donating Lower Bound cannot be reached');
    }
  }

  int getDonatingLowerLevelBound() => _donatingLowerLevelBound;
  CdomSingleRef<PCClass> getExchangeClass() => _exchangeClass;
  int getMaxDonatedLevels() => _maxDonatedLevels;
  int getMinDonatingLevel() => _minDonatingLevel;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LevelExchange) return false;
    return _minDonatingLevel == other._minDonatingLevel &&
        _maxDonatedLevels == other._maxDonatedLevels &&
        _donatingLowerLevelBound == other._donatingLowerLevelBound &&
        _exchangeClass == other._exchangeClass;
  }

  @override
  int get hashCode => _minDonatingLevel * 23 + _maxDonatedLevels * 31 + _donatingLowerLevelBound;
}
