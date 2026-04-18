// Translation of pcgen.system.PropertyContext

/// Hierarchical property storage. Child contexts share a parent's properties
/// but write into a namespaced sub-tree.
class PropertyContext {
  final String name;
  final PropertyContext? parent;
  final Map<String, String> _properties = {};

  PropertyContext(this.name, [this.parent]);

  String? getProperty(String key) =>
      _properties[key] ?? parent?.getProperty(key);

  void setProperty(String key, String value) => _properties[key] = value;

  bool hasProperty(String key) =>
      _properties.containsKey(key) || (parent?.hasProperty(key) ?? false);

  PropertyContext createChildContext(String childName) =>
      PropertyContext(childName, this);

  Map<String, String> toMap() {
    final map = <String, String>{};
    if (parent != null) map.addAll(parent!.toMap());
    map.addAll(_properties);
    return map;
  }
}
