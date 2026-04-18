class OrderedPair {
  final num x;
  final num y;

  const OrderedPair(this.x, this.y);

  static OrderedPair? fromString(String value) {
    final parts = value.split(',');
    if (parts.length != 2) return null;
    final x = num.tryParse(parts[0].trim());
    final y = num.tryParse(parts[1].trim());
    if (x == null || y == null) return null;
    return OrderedPair(x, y);
  }

  @override
  String toString() => '$x,$y';

  @override
  bool operator ==(Object other) =>
      other is OrderedPair && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);
}
