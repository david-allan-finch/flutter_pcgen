// Translation of pcgen.gui2.PCGenUIManager

import 'pc_gen_frame.dart';
import 'ui_context.dart';

/// Responsible for starting up and shutting down PCGen's main window.
/// Provides static methods for external UI frameworks (e.g. Mac app toolbar).
class PCGenUIManager {
  static PCGenFrame? _pcgenFrame;

  PCGenUIManager._();

  static void initializeGUI() {
    _pcgenFrame = PCGenFrame(UIContext());
  }

  static void startGUI() {
    _pcgenFrame?.startPCGenFrame();
  }

  static void displayPreferencesDialog() {
    _pcgenFrame?.showPreferencesDialog();
  }

  static void displayAboutDialog() {
    _pcgenFrame?.showAboutDialog();
  }

  static void closePCGen() {
    final frame = _pcgenFrame;
    if (frame != null) {
      if (!frame.closeAllCharacters()) return;
      frame.dispose();
    }
  }
}
