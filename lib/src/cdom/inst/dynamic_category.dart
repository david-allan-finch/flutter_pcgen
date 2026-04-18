import 'abstract_category.dart';
import 'dynamic.dart';

// A non-hierarchical Category used to separate typed Dynamic objects.
final class DynamicCategory extends AbstractCategory<Dynamic> {
  @override
  Type get referenceClass => Dynamic;

  @override
  String getReferenceDescription() => '${getKeyName()} (Dynamic)';

  @override
  Dynamic newInstance() {
    final instance = Dynamic();
    instance.setCDOMCategory(this);
    return instance;
  }

  @override
  String getPersistentFormat() => getKeyName().toUpperCase();
}
