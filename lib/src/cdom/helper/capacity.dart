// Represents the carrying capacity of a container equipment item.
class Capacity {
  static const double unlimited = -1.0;
  static final Capacity any = Capacity(null, unlimited);

  final String? type;
  final double limit;

  Capacity(this.type, this.limit);

  double getCapacity() => limit;
  String? getType() => type;

  static Capacity getTotalCapacity(double capacity) => Capacity(null, capacity);

  @override
  String toString() {
    final typeStr = type ?? 'Total';
    final limitStr = limit == unlimited ? 'UNLIMITED' : limit.toString();
    return 'Capacity: $typeStr=$limitStr';
  }

  @override
  bool operator ==(Object other) {
    if (other is Capacity) {
      return type == other.type && limit == other.limit;
    }
    return false;
  }

  @override
  int get hashCode => (type?.hashCode ?? 0) ^ limit.hashCode;
}
