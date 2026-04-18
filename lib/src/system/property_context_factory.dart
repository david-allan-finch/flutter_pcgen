// Translation of pcgen.system.PropertyContextFactory

import 'property_context.dart';

/// Creates and manages PropertyContext instances, loading/saving them
/// from a specified directory.
class PropertyContextFactory {
  static PropertyContextFactory? _defaultFactory;

  final String dir;
  final Map<String, PropertyContext> _contextMap = {};

  PropertyContextFactory(this.dir);

  static PropertyContextFactory? getDefaultFactory() => _defaultFactory;

  static void setDefaultFactory(String dir) {
    _defaultFactory = PropertyContextFactory(dir);
  }

  void registerAndLoadPropertyContext(PropertyContext context) {
    _contextMap[context.name] = context;
    // TODO: load properties from file
  }

  PropertyContext? getPropertyContext(String name) => _contextMap[name];
}
