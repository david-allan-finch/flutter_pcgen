import '../kit.dart';
import '../player_character.dart';
import 'base_kit.dart';

class KitFunds extends BaseKit {
  String _name = '';
  String? _quantityFormula; // formula string
  double _theQty = 0.0;

  @override
  void setName(String value) { _name = value; }
  String getName() => _name;

  void setQuantity(String formula) { _quantityFormula = formula; }
  String? getQuantity() => _quantityFormula;

  @override
  bool testApply(Kit? aKit, PlayerCharacter aPC, List<String>? warnings) {
    if (_quantityFormula == null) return false;
    _theQty = aPC.getVariableValue(_quantityFormula!, '').toDouble();
    return true;
  }

  @override
  void apply(PlayerCharacter aPC) {
    aPC.adjustFunds(_theQty);
  }

  @override
  String getObjectName() => 'Funds';

  @override
  String toString() => '${_quantityFormula ?? ''} $_name';
}
