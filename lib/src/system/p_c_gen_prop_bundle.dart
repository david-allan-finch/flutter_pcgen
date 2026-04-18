// Translation of pcgen.system.PCGenPropBundle

/// Manages properties for the PCGen application.
class PCGenPropBundle {
  static final Map<String, String> _properties = {};

  PCGenPropBundle._();

  static String? getProperty(String key) => _properties[key];

  static void setProperty(String key, String value) =>
      _properties[key] = value;

  static bool hasProperty(String key) => _properties.containsKey(key);
}
