// Translation of pcgen.system.Main

import '../pluginmgr/plugin_manager.dart';
import 'character_manager.dart';
import 'configuration_settings.dart';
import 'facade_factory.dart';

/// Application entry point and initialization logic.
final class Main {
  Main._();

  /// Initialize PCGen subsystems. Call once at startup.
  static void startup() {
    ConfigurationSettings.getInstance();
    FacadeFactory._();
    CharacterManager._();
    PluginManager.getInstance();
    // TODO: load game data, LST tokens, etc.
  }

  /// Shutdown PCGen subsystems cleanly.
  static void shutdown() {
    // TODO: save settings, close characters, etc.
  }
}
