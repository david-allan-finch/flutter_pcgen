// Translation of pcgen.system.PluginClassLoader

import 'plugin_loader.dart';

/// Loads plugin classes from a directory.
class PluginClassLoader implements PluginLoader {
  final String pluginDir;
  final List<Type> _supportedTypes = [];

  PluginClassLoader(this.pluginDir);

  @override
  void loadPlugin(Type pluginClass) {
    // TODO: full implementation
  }

  @override
  List<String> getPluginTypes() => _supportedTypes.map((t) => t.toString()).toList();

  void addSupportedType(Type type) => _supportedTypes.add(type);
}
