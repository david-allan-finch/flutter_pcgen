/*
 * Copyright (c) Thomas Parker, 2009.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
 */

import '../../enumeration/char_id.dart';

/// SubRaceFacet is a Facet that returns information about the SubRace of a
/// Player Character.
class SubRaceFacet {
  dynamic templateFacet;

  /// Returns the SubRace of the Player Character represented by the given
  /// CharID.
  String? getSubRace(CharID id) {
    String? subRace;

    for (final template in templateFacet.getSet(id)) {
      final tempSubRace = _getTemplateSubRace(template);
      if (tempSubRace != null) {
        subRace = tempSubRace;
      }
    }

    return subRace;
  }

  String? _getTemplateSubRace(dynamic template) {
    // TODO: This should be type safe to return a SubRace
    final sr = template.get('SUBRACE');
    if (sr == null) {
      if (template.getSafe('USETEMPLATENAMEFORSUBRACE') == true) {
        return template.getDisplayName() as String?;
      }
      return null;
    }
    return sr.toString();
  }

  void setTemplateFacet(dynamic templateFacet) {
    this.templateFacet = templateFacet;
  }
}
