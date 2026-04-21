// *
// Copyright James Dempsey, 2010
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
// Translation of pcgen.gui2.facade.LanguageChooserFacadeImpl

import 'package:flutter_pcgen/src/gui2/facade/general_chooser_facade_base.dart';

/// Chooser facade for selecting languages for a character.
class LanguageChooserFacadeImpl extends GeneralChooserFacadeBase<String> {
  final dynamic _character;

  LanguageChooserFacadeImpl(this._character, List<String> available, int maxSelections)
      : super(
          name: 'Choose Languages',
          available: available,
          selected: _extractSelected(_character),
          maxSelections: maxSelections,
        );

  static List<String> _extractSelected(dynamic character) {
    if (character == null) return [];
    if (character is Map) {
      final langs = character['languages'];
      if (langs is List) return langs.cast<String>();
    }
    return [];
  }

  @override
  void commit() {
    // Write selected languages back to character
    if (_character is Map) {
      _character['languages'] = List.of(
        Iterable.generate(getSelectedList().getSize(),
            (i) => getSelectedList().getElementAt(i) as String),
      );
    }
    super.commit();
  }
}
