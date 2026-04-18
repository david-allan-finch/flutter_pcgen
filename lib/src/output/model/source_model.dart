// Translation of pcgen.output.model.SourceModel

/// Output model for the source (campaign/book) of an object.
class SourceModel {
  final dynamic _obj;
  SourceModel(this._obj);
  @override
  String toString() => _obj?.getSource() ?? '';
}
