import 'category.dart';
import 'loadable.dart';

/// Categorized represents an object which can possess a Category object.
/// This Category is used for establishing unique identity of an object.
abstract interface class Categorized<T extends Categorized<T>>
    implements Loadable {
  /// Returns the Category of the Categorized object.
  Category<T> getCDOMCategory();

  /// Sets the Category of the Categorized object.
  void setCDOMCategory(Category<T> category);

  /// Returns the ClassIdentity for this Categorized object (its category).
  ClassIdentity<Loadable> getClassIdentity() => getCDOMCategory();
}
