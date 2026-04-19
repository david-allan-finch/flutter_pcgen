// Translation of pcgen.persistence.lst.WieldCategoryLoader

import '../../rules/context/load_context.dart';
import 'simple_loader.dart';

/// Loads WieldCategory objects from wieldcategory .lst files.
///
/// WieldCategories define how weapons can be wielded (Light, One-Handed,
/// Two-Handed, etc.) and the switching rules between them.
class WieldCategoryLoader extends SimpleLoader<dynamic> {
  WieldCategoryLoader() : super(dynamic);

  @override
  dynamic getLoadable(dynamic context, String firstToken, Uri sourceUri) {
    if (firstToken.isEmpty) return null;
    // TODO: construct WieldCategory via context.getReferenceContext()
    // and register it. Full implementation requires WieldCategoryLstToken dispatch.
    return null;
  }
}
