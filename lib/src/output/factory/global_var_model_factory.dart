// Translation of pcgen.output.factory.GlobalVarModelFactory

import '../base/model_factory.dart';
import '../model/global_var_model.dart';

/// A ModelFactory for global (non-PC) variable values.
class GlobalVarModelFactory implements ModelFactory {
  final dynamic _value;

  GlobalVarModelFactory(this._value);

  @override
  dynamic generate(String charId) => GlobalVarModel(_value);
}
