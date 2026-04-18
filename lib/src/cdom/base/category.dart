import 'categorized.dart';
import 'loadable.dart';

// ClassIdentity stub - used until ClassIdentity is fully translated
abstract interface class ClassIdentity<T> {
  String getName();
  Type getReferenceClass();
  T newInstance();
  String getReferenceDescription();
  bool isMember(T item);
  String getPersistentFormat();
}

/// Category identifies an object and is used for establishing unique identity
/// of an object. A Category serves as a Category for a particular type of
/// CategorizedCDOMObject.
abstract interface class Category<T extends Categorized<T>>
    implements Loadable, ClassIdentity<T> {
  /// Returns the Parent Category for the current Category. Returns null if
  /// the current Category is a "root" Category.
  Category<T>? getParentCategory();
}
