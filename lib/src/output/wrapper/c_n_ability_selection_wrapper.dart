// Translation of pcgen.output.wrapper.CNAbilitySelectionWrapper

import '../base/p_c_gen_object_wrapper.dart';
import '../model/c_n_ability_selection_model.dart';

/// Wraps CNAbilitySelection objects into output models.
class CNAbilitySelectionWrapper implements PCGenObjectWrapper {
  @override
  dynamic wrap(String charId, Object obj) {
    return CNAbilitySelectionModel(charId, obj);
  }
}
