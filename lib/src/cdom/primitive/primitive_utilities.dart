//
// Copyright (c) 2010 Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.primitive.PrimitiveUtilities
// Utility methods for working with PrimitiveCollection objects.
final class PrimitiveUtilities {
  PrimitiveUtilities._();

  // Sorts PrimitiveCollection objects by LST format string.
  static int collectionSorter(dynamic a, dynamic b) =>
      (a.getLSTformat(false) as String)
          .compareTo(b.getLSTformat(false) as String);

  // Joins the LST formats of a collection of PrimitiveCollection objects.
  static String joinLstFormat(
      Iterable<dynamic> pcCollection, String separator, bool useAny) =>
      pcCollection
          .map((pcf) => pcf.getLSTformat(useAny) as String)
          .join(separator);
}
