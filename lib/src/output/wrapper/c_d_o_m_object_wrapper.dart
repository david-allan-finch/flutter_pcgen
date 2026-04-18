// Translation of pcgen.output.wrapper.CDOMObjectWrapper

import '../base/p_c_gen_object_wrapper.dart';
import '../model/c_d_o_m_object_model.dart';

/// Wraps CDOMObject objects into output models using a CharID.
class CDOMObjectWrapper implements PCGenObjectWrapper {
  @override
  dynamic wrap(String charId, Object obj) {
    // TODO: look up OutputActor map from CDOMWrapperInfoFacet
    return CDOMObjectModel(charId, obj, const {});
  }
}
