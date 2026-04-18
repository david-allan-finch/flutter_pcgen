// Translation of pcgen.pluginmgr.PluginManager

import 'message_handler_manager.dart';
import 'p_c_gen_message.dart';
import 'p_c_gen_message_handler.dart';

/// Singleton plugin manager that dispatches messages to registered plugins.
final class PluginManager {
  static PluginManager? _instance;

  final MessageHandlerManager _msgHandlerMgr = MessageHandlerManager();

  PluginManager._();

  static PluginManager getInstance() {
    _instance ??= PluginManager._();
    return _instance!;
  }

  void addMember(PCGenMessageHandler handler) =>
      _msgHandlerMgr.addMember(handler);

  void removeMember(PCGenMessageHandler handler) =>
      _msgHandlerMgr.removeMember(handler);

  void sendMessage(PCGenMessage msg) => _msgHandlerMgr.handleMessage(msg);
}
