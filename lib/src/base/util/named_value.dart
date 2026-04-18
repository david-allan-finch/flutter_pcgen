class NamedValue {
  final String name;
  final double value;

  const NamedValue(this.name, this.value);

  @override
  String toString() => '$name: $value';
}
