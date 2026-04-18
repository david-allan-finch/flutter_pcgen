// Translation of pcgen.pluginmgr.messages.ComponentAddedMessage

import '../p_c_gen_message.dart';
import '../p_c_gen_message_handler.dart';

/// Indicates that a plugin has been added to the system.
class ComponentAddedMessage extends PCGenMessage {
  final PCGenMessageHandler plugin;

  ComponentAddedMessage(Object source, this.plugin) : super(source);

  PCGenMessageHandler getPlugin() => plugin;
}
