// Translation of pcgen.pluginmgr.InteractivePlugin

import 'p_c_gen_message_handler.dart';

/// Defines the interface for interactive UI plugins in PCGen.
abstract interface class InteractivePlugin implements PCGenMessageHandler {
  int getPriority();
  String getPluginName();
}
