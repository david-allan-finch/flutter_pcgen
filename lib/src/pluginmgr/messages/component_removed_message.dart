// Translation of pcgen.pluginmgr.messages.ComponentRemovedMessage

import '../p_c_gen_message.dart';
import '../p_c_gen_message_handler.dart';

/// Indicates that a plugin has been removed from the system.
class ComponentRemovedMessage extends PCGenMessage {
  final PCGenMessageHandler plugin;

  ComponentRemovedMessage(Object source, this.plugin) : super(source);

  PCGenMessageHandler getPlugin() => plugin;
}
