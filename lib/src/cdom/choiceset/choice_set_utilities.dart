//
// Copyright (c) 2008 Tom Parker <thpr@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.cdom.choiceset.ChoiceSetUtilities
// Utility methods for working with PrimitiveChoiceSet-like objects.
class ChoiceSetUtilities {
  ChoiceSetUtilities._();

  // Compares two choice set objects by their LST format string.
  // Returns 0 if equal, negative if pcs1 sorts first, positive if pcs2 sorts first.
  static int compareChoiceSets(dynamic pcs1, dynamic pcs2) {
    final String? base = pcs1.getLSTformat(false) as String?;
    final String? other = pcs2.getLSTformat(false) as String?;
    if (base == null) {
      return other == null ? 0 : -1;
    } else {
      if (other == null) {
        return 1;
      } else {
        return base.compareTo(other);
      }
    }
  }

  // Concatenates the LST format of a collection of choice sets using a separator.
  // Returns an empty string if the collection is null.
  static String joinLstFormat(
    Iterable? pcsCollection,
    String separator,
    bool useAny,
  ) {
    if (pcsCollection == null) {
      return '';
    }
    final StringBuffer result = StringBuffer();
    bool needJoin = false;
    for (final dynamic pcs in pcsCollection) {
      if (needJoin) {
        result.write(separator);
      }
      needJoin = true;
      result.write(pcs.getLSTformat(useAny) as String);
    }
    return result.toString();
  }
}
