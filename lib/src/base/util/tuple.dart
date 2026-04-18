class Tuple<A, B> {
  final A first;
  final B second;

  const Tuple(this.first, this.second);

  @override
  bool operator ==(Object other) =>
      other is Tuple && first == other.first && second == other.second;

  @override
  int get hashCode => Object.hash(first, second);

  @override
  String toString() => '($first, $second)';
}
