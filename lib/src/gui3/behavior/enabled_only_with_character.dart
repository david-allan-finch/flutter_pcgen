//
// Copyright 2019 (C) Eitan Adler <lists@eitanadler.com>
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
// Translation of pcgen.gui3.behavior.EnabledOnlyWithCharacter

import 'package:flutter/foundation.dart';

/// A ValueNotifier<bool> that is true only when a character is loaded.
/// Used to control the enabled state of buttons/menu items that require
/// an open character.
class EnabledOnlyWithCharacter extends ValueNotifier<bool> {
  EnabledOnlyWithCharacter() : super(false);

  void onCharacterLoaded(dynamic character) {
    value = character != null;
  }

  void onCharacterClosed() {
    value = false;
  }
}
