// Translation of pcgen.output.model.VisibleToModel

/// Output model that reports visibility of an object for a given view.
class VisibleToModel {
  final dynamic _obj;
  final dynamic _view;

  VisibleToModel(this._obj, this._view);

  bool get isVisible => _obj?.isVisibleTo(_view) ?? false;

  @override
  String toString() => isVisible.toString();
}
