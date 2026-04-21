//
// Copyright (c) Thomas Parker, 2013.
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
// Translation of pcgen.cdom.facet.event.ScopeFacetChangeListener
import 'package:flutter_pcgen/src/cdom/base/pcgen_identifier.dart';
import 'scope_facet_change_event.dart';

abstract interface class ScopeFacetChangeListener<IDT extends PCGenIdentifier, S, T> {
  void dataAdded(ScopeFacetChangeEvent<IDT, S, T> dfce);
  void dataRemoved(ScopeFacetChangeEvent<IDT, S, T> dfce);
}
