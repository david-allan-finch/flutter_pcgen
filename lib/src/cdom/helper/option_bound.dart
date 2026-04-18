import '../../core/player_character.dart';

// Represents an inclusive range of values defined by two optional Formulas.
class OptionBound {
  final dynamic _minOption; // Formula?
  final dynamic _maxOption; // Formula?

  OptionBound(dynamic min, dynamic max)
      : _minOption = min,
        _maxOption = max;

  bool isOption(PlayerCharacter pc, int value) {
    if (_minOption != null &&
        _minOption.resolve(pc, '').toInt() > value) return false;
    if (_maxOption != null &&
        _maxOption.resolve(pc, '').toInt() < value) return false;
    return true;
  }

  dynamic getOptionMin() => _minOption;
  dynamic getOptionMax() => _maxOption;
}
