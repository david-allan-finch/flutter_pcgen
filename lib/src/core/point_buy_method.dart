import '../cdom/base/bonus_container.dart';
import '../cdom/base/loadable.dart';
import 'bonus/bonus_obj.dart';

// Represents a point-buy method (e.g. "28-Point Buy") from the game mode.
final class PointBuyMethod implements BonusContainer, Loadable {
  String? _sourceUri;
  String _methodName = '';
  String _pointFormula = '0';
  final List<BonusObj> _bonusList = [];

  @override
  String? getSourceURI() => _sourceUri;

  @override
  void setSourceURI(String source) => _sourceUri = source;

  String getPointFormula() => _pointFormula;
  void setPointFormula(String formula) => _pointFormula = formula;

  String getDescription() {
    var desc = _methodName;
    if (_pointFormula != '0') desc += ' ($_pointFormula)';
    return desc;
  }

  void addBonus(BonusObj bon) => _bonusList.add(bon);
  List<BonusObj> getBonusList() => List.unmodifiable(_bonusList);

  @override
  List<BonusObj> getRawBonusList() => _bonusList;

  @override
  String getKeyName() => _methodName;

  @override
  void setName(String name) => _methodName = name;

  @override
  String getDisplayName() => _methodName;

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;

  @override
  String toString() => _methodName;
}
