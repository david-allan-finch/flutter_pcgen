// Translation of pcgen.pluginmgr.messages.FocusOrStateChangeOccurredMessage

import '../p_c_gen_message.dart';

/// Signals that the user switched between GMGen and PCGen.
class FocusOrStateChangeOccurredMessage extends PCGenMessage {
  // editMenu is a Java Swing JMenu — represented as dynamic here.
  final dynamic editMenu;

  FocusOrStateChangeOccurredMessage(Object source, this.editMenu)
      : super(source);

  dynamic getEditMenu() => editMenu;
}
