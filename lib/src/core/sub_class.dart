import '../cdom/base/categorized.dart';
import '../cdom/base/category.dart';
import '../cdom/enumeration/integer_key.dart';
import '../cdom/enumeration/object_key.dart';
import 'pc_class.dart';

// A specialized variant of a PCClass with modified spell prohibition and cost.
final class SubClass extends PCClass implements Categorized<SubClass> {
  String getChoice() {
    final sp = get(ObjectKey.choice);
    if (sp == null) return '';
    // SpellProhibitor value list — simplified
    return sp.toString();
  }

  int getProhibitCost() {
    final prohib = get(IntegerKey.prohibitCost) as int?;
    if (prohib != null) return prohib;
    return getSafe<int>(IntegerKey.cost) ?? 0;
  }

  @override
  Category<SubClass>? getCDOMCategory() {
    return get(ObjectKey.subclassCategory) as Category<SubClass>?;
  }

  @override
  void setCDOMCategory(Category<SubClass>? cat) {
    put(ObjectKey.subclassCategory, cat);
  }

  @override
  String getFullKey() => '${getCDOMCategory()}.${super.getFullKey()}';
}
