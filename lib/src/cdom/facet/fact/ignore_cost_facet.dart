//
// Copyright (c) Thomas Parker, 2009-12.
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
// Translation of pcgen.cdom.facet.fact.IgnoreCostFacet
// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/fact/IgnoreCostFacet.java

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_item_facet.dart';

/// IgnoreCostFacet is a Facet to track whether a character should ignore cost
/// when purchasing items.
class IgnoreCostFacet extends AbstractItemFacet<CharID, bool> {}
