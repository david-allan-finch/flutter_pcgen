//
// Copyright 2008 Connor Petty <cpmeister@users.sourceforge.net>
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
