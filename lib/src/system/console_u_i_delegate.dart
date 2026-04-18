// Translation of pcgen.system.ConsoleUIDelegate

import '../facade/core/ui_delegate.dart';

/// A minimal UIDelegate that logs to the console (no GUI).
class ConsoleUIDelegate implements UIDelegate {
  @override
  bool? maybeShowWarningConfirm(
      String title, String message, String checkBoxText) {
    print('[WARN] $title: $message');
    return true;
  }

  @override
  void showErrorMessage(String title, String message) =>
      print('[ERROR] $title: $message');

  @override
  void showInfoMessage(String title, String message) =>
      print('[INFO] $title: $message');

  @override
  void showLevelUpInfo(dynamic character, int oldLevel) {
    // no-op in console mode
  }

  @override
  bool showWarningConfirm(String title, String message) {
    print('[WARN CONFIRM] $title: $message');
    return true;
  }

  @override
  void showWarningMessage(String title, String message) =>
      print('[WARN] $title: $message');

  @override
  bool showGeneralChooser(dynamic chooserFacade) => false;

  @override
  String? showInputDialog(String title, String message, String? initialValue) =>
      null;

  @override
  bool showCustomSpellDialog(dynamic spellBuilderFacade) => false;
}
