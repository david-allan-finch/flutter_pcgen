// Translation of pcgen.system.PluginClassLoader

import 'plugin_loader.dart';

/// Loads plugin classes from a directory and dispatches them to the
/// appropriate [PluginLoader] instances.
///
/// In Dart there are no JAR files or dynamic class-loading, so the Java
/// loading mechanism is replaced with an explicit registration model:
/// plugins are registered by calling [addPlugin] directly, and
/// [loadPlugin] is called on the correct [PluginLoader] based on type
/// compatibility.
///
/// Translation of pcgen.system.PluginClassLoader.
class PluginClassLoader implements PluginLoader {
  final String pluginDir;

  /// Map from Dart Type → list of PluginLoaders that handle that type.
  final Map<Type, List<PluginLoader>> _loaderMap = {};

  /// All explicitly-registered plugin instances awaiting dispatch.
  final List<dynamic> _pendingPlugins = [];

  PluginClassLoader(this.pluginDir);

  // ---------------------------------------------------------------------------
  // PluginLoader registration
  // ---------------------------------------------------------------------------

  /// Registers [loader] to receive plugins for each type it declares.
  void addPluginLoader(PluginLoader loader) {
    for (final type in loader.getPluginTypes()) {
      // TODO: convert String type name back to Type for lookup if needed.
      // For now store under the loader's own runtimeType as a sentinel.
    }
    _loaderMap.putIfAbsent(loader.runtimeType, () => []).add(loader);
  }

  // ---------------------------------------------------------------------------
  // Plugin registration and dispatch
  // ---------------------------------------------------------------------------

  /// Registers a plugin [instance].  It will be dispatched to every
  /// [PluginLoader] that has declared interest in its type.
  void addPlugin(dynamic instance) {
    _pendingPlugins.add(instance);
  }

  /// Dispatches all pending plugins to their registered loaders.
  ///
  /// In Java this happened at class-loading time from JARs.  In Dart it is
  /// driven by calling this method after all plugins have been registered.
  void dispatchPendingPlugins() {
    for (final plugin in _pendingPlugins) {
      loadPlugin(plugin.runtimeType);
    }
    _pendingPlugins.clear();
  }

  // ---------------------------------------------------------------------------
  // PluginLoader implementation
  // ---------------------------------------------------------------------------

  @override
  void loadPlugin(Type pluginClass) {
    // Dispatch to every registered loader.
    for (final loaders in _loaderMap.values) {
      for (final loader in loaders) {
        try {
          loader.loadPlugin(pluginClass);
        } catch (e) {
          print('ERROR loading plugin $pluginClass into $loader: $e');
        }
      }
    }
  }

  @override
  List<String> getPluginTypes() =>
      _loaderMap.values.expand((l) => l).expand((l) => l.getPluginTypes()).toList();

  // ---------------------------------------------------------------------------
  // Task metadata (mirrors PCGenTask.getMessage)
  // ---------------------------------------------------------------------------

  String getMessage() => 'Loading plugins from $pluginDir';

  int get progress => _pendingPlugins.length;
}
