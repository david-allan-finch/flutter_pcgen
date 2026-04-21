// *
// Copyright James Dempsey, 2012
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
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
