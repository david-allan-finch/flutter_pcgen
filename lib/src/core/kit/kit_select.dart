import '../kit.dart';
import '../player_character.dart';
import 'base_kit.dart';

final class KitSelect extends BaseKit {
  String? _formula; // formula string

  String? getFormula() => _formula;
  void setFormula(String formula) { _formula = formula; }

  @override
  bool testApply(Kit aKit, PlayerCharacter aPC, List<String> warnings) {
    if (_formula != null) {
      aKit.setSelectValue(aPC.getVariableValue(_formula!, '').toInt());
    }
    return true;
  }

  @override
  void apply(PlayerCharacter aPC) {} // nothing to do

  @override
  String getObjectName() => 'Select';

  @override
  String toString() => _formula ?? '';
}
