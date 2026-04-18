// Translation of pcgen.pluginmgr.MessageHandlerManager

import 'p_c_gen_message.dart';
import 'p_c_gen_message_handler.dart';

/// Records message handlers and dispatches messages to them in order.
class MessageHandlerManager {
  final List<PCGenMessageHandler> _chain = [];

  void addMember(PCGenMessageHandler handler) => _chain.add(handler);

  void removeMember(PCGenMessageHandler handler) => _chain.remove(handler);

  void handleMessage(PCGenMessage msg) {
    for (final handler in List.of(_chain)) {
      handler.handleMessage(msg);
    }
  }
}
