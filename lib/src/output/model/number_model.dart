// Translation of pcgen.output.model.NumberModel

/// Output model wrapping a numeric value.
class NumberModel {
  final num value;
  NumberModel(this.value);
  @override
  String toString() => value.toString();
}
