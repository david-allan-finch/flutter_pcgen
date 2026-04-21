//
// Copyright 2009 (C) James Dempsey
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
// Translation of pcgen.cdom.helper.SpringHelper
// Stub for Spring framework integration — not applicable in the Dart/Flutter port.
// PCGen uses Spring to instantiate AbstractStorageFacet beans from XML config.
// In Dart, facet registration is handled directly rather than via IoC container.
final class SpringHelper {
  SpringHelper._();

  // Returns all registered AbstractStorageFacet instances.
  static List<dynamic> getStorageFacets() => const [];
}
