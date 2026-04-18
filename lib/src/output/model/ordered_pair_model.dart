// Translation of pcgen.output.model.OrderedPairModel

/// Output model wrapping an OrderedPair value.
class OrderedPairModel {
  final dynamic _pair;
  OrderedPairModel(this._pair);
  @override
  String toString() => _pair?.toString() ?? '';
}
