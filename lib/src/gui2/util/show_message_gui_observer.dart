// Translation of pcgen.gui2.util.ShowMessageGuiObserver

import '../../core/utils/message_type.dart';
import '../../core/utils/message_wrapper.dart';
import '../../facade/core/ui_delegate.dart';

/// Observes a stream of [MessageWrapper] objects and delegates display to the
/// [UIDelegate] using the appropriate severity method.
class ShowMessageGuiObserver {
  final UIDelegate _uiDelegate;

  ShowMessageGuiObserver(this._uiDelegate);

  void update(Object? arg) {
    if (arg is MessageWrapper) {
      showMessageDialog(arg);
    }
  }

  void showMessageDialog(MessageWrapper messageWrapper) {
    final MessageType mt = messageWrapper.messageType;
    String title = messageWrapper.title ?? 'PCGen';
    final String message = messageWrapper.message?.toString() ?? '';

    if (mt == MessageType.warning) {
      _uiDelegate.showWarningMessage(title, message);
    } else if (mt == MessageType.error) {
      _uiDelegate.showErrorMessage(title, message);
    } else {
      _uiDelegate.showInfoMessage(title, message);
    }
  }
}
