//
// Missing License Header, Copyright 2016 (C) Andrew Maitland <amaitland@users.sourceforge.net>
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
// Translation of pcgen.gui2.tabs.models.DeferredCharacterComboBoxModel

import 'package:flutter_pcgen/src/gui2/tabs/models/character_combo_box_model.dart';

/// A CharacterComboBoxModel whose item list is populated lazily on first access.
class DeferredCharacterComboBoxModel<T> extends CharacterComboBoxModel<T> {
  bool _loaded = false;

  DeferredCharacterComboBoxModel({
    required super.selectedReader,
    required super.itemsReader,
    super.writer,
  });

  @override
  void install(dynamic character) {
    if (!_loaded) {
      _loaded = true;
      super.install(character);
    } else {
      // Re-read selected only
      final sel = items.isNotEmpty ? items.first : null;
      selected = sel;
    }
  }

  void reset() {
    _loaded = false;
  }
}
