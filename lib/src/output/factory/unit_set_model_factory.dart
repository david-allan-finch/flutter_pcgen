// Translation of pcgen.output.factory.UnitSetModelFactory

import '../base/mode_model_factory.dart';
import '../model/unit_set_model.dart';

/// A ModeModelFactory that produces UnitSetModel for the current GameMode.
class UnitSetModelFactory implements ModeModelFactory {
  @override
  dynamic generate(dynamic mode) {
    final unitSet = mode?.getUnitSet();
    return UnitSetModel(unitSet);
  }
}
