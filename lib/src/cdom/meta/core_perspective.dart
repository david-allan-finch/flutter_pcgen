// Named perspective for displaying facet data (e.g. "Granted Languages").
final class CorePerspective {
  static final CorePerspective language = CorePerspective._('Granted Languages');
  static final CorePerspective domain = CorePerspective._('Granted Domains');
  static final CorePerspective armorprof = CorePerspective._('Armor Proficiencies');
  static final CorePerspective shieldprof = CorePerspective._('Shield Proficiencies');

  static final Map<String, CorePerspective> _map = {
    'LANGUAGE': language,
    'DOMAIN': domain,
    'ARMORPROF': armorprof,
    'SHIELDPROF': shieldprof,
  };

  final String _name;

  CorePerspective._(String name) : _name = name;

  @override
  String toString() => _name;

  static List<CorePerspective> getAllConstants() => List.unmodifiable(_map.values);
}
