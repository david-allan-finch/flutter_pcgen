import '../cdom/base/concrete_prereq_object.dart';
import '../cdom/base/loadable.dart';

// Represents the cost (in points) to purchase a specific stat value in
// point-buy character creation.
final class PointBuyCost extends ConcretePrereqObject implements Loadable {
  String? _sourceUri;
  int _statValue = 0;
  int _buyCost = 0;

  @override
  String? getSourceURI() => _sourceUri;

  @override
  void setSourceURI(String source) => _sourceUri = source;

  @override
  String getDisplayName() => _statValue.toString();

  @override
  void setName(String name) {
    final parsed = int.tryParse(name);
    if (parsed == null) {
      throw ArgumentError('Name for a PointBuyCost must be an integer, found: $name');
    }
    _statValue = parsed;
  }

  @override
  String getKeyName() => _statValue.toString();

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;

  int getStatValue() => _statValue;

  void setBuyCost(int cost) => _buyCost = cost;
  int getBuyCost() => _buyCost;
}
