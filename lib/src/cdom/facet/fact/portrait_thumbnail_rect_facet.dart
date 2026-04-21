//
// Copyright (c) James Dempsey 2011.
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
// Translation of pcgen.cdom.facet.fact.PortraitThumbnailRectFacet
// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/fact/PortraitThumbnailRectFacet.java

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_item_facet.dart';

/// PortraitThumbnailRectFacet is a Facet that tracks the thumbnail rectangle
/// for the character's portrait.
///
/// Note: Java's java.awt.Rectangle is represented as dynamic here since there
/// is no direct Dart equivalent in this codebase.
class PortraitThumbnailRectFacet extends AbstractItemFacet<CharID, dynamic> {}
