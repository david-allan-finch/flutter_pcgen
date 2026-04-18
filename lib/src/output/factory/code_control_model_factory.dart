// Translation of pcgen.output.factory.CodeControlModelFactory

import '../base/mode_model_factory.dart';
import '../model/code_control_model.dart';

/// A ModeModelFactory that produces CodeControlModel for the current GameMode.
class CodeControlModelFactory implements ModeModelFactory {
  @override
  dynamic generate(dynamic mode) {
    final controller = mode?.getModeContext()
        ?.getReferenceContext()
        ?.silentlyGetConstructedCDOMObject('CodeControl', 'Controller');
    if (controller == null) return null;
    return CodeControlModel(controller);
  }
}
