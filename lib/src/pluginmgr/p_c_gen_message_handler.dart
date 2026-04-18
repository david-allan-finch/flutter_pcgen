// Translation of pcgen.pluginmgr.PCGenMessageHandler

import 'p_c_gen_message.dart';

/// Handles PCGen messages.
abstract interface class PCGenMessageHandler {
  void handleMessage(PCGenMessage msg);
}
