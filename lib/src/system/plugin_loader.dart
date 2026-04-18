// Translation of pcgen.system.PluginLoader

/// Interface for loading plugins into PCGen.
abstract interface class PluginLoader {
  void loadPlugin(Type pluginClass);
  List<String> getPluginTypes();
}
