// Categorizes how a facet is used (Model, Input, Conditional, etc.).
final class FacetBehavior {
  static final FacetBehavior model = FacetBehavior._('Model');
  static final FacetBehavior input = FacetBehavior._('Input');
  static final FacetBehavior conditional = FacetBehavior._('Conditional');
  static final FacetBehavior conditionalGranted = FacetBehavior._('Conditional-Granted');

  static final Map<String, FacetBehavior> _map = {
    'MODEL': model,
    'INPUT': input,
    'CONDITIONAL': conditional,
    'CONDITIONAL-GRANTED': conditionalGranted,
  };

  final String _type;

  FacetBehavior._(String type) : _type = type;

  static FacetBehavior getKeyFor(String type) =>
      _map.putIfAbsent(type.toUpperCase(), () => FacetBehavior._(type));

  @override
  String toString() => _type;

  static List<FacetBehavior> getAllConstants() => List.unmodifiable(_map.values);
}
