// Translation of pcgen.output.wrapper.CategoryWrapper

import '../base/simple_object_wrapper.dart';
import '../model/category_model.dart';

/// Wraps Category objects into output models.
class CategoryWrapper implements SimpleObjectWrapper {
  @override
  dynamic wrap(Object obj) {
    // TODO: check for Category type when Category is defined
    return CategoryModel(obj);
  }
}
