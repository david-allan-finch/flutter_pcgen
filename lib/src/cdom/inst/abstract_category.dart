import '../base/categorized.dart';
import '../base/category.dart';

// Base class for Category objects that categorize Categorized objects.
abstract class AbstractCategory<T extends Categorized<T>> implements Category<T> {
  String? _categoryName;
  String? _sourceURI;

  @override
  Category<T>? getParentCategory() => null;

  @override
  String getKeyName() => _categoryName ?? '';

  @override
  String? getDisplayName() => _categoryName;

  @override
  String? getSourceURI() => _sourceURI;

  @override
  void setSourceURI(String? source) { _sourceURI = source; }

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;

  @override
  void setName(String name) { _categoryName = name; }

  @override
  bool isMember(T item) => item.getCDOMCategory() == this;

  @override
  String toString() => _categoryName ?? '';

  @override
  int get hashCode => (_categoryName ?? '').hashCode ^ runtimeType.hashCode;

  @override
  bool operator ==(Object o) =>
      runtimeType == o.runtimeType &&
      o is AbstractCategory<T> &&
      _categoryName == o._categoryName;
}
