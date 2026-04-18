// Translation of pcgen.output.model.CategoryModel

/// Output model wrapping a Category object.
class CategoryModel {
  final dynamic _category;
  CategoryModel(this._category);
  @override
  String toString() => _category?.toString() ?? '';
}
