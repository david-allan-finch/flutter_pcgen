// Translation of pcgen.output.model.CodeControlModel

/// Output model wrapping a CodeControl object.
class CodeControlModel {
  final dynamic _controller;
  CodeControlModel(this._controller);
  @override
  String toString() => _controller?.toString() ?? '';
}
