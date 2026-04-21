// Copyright (c) Thomas Parker, 2012.
//
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License as published by the
// Free Software Foundation; either version 2.1 of the License, or (at your
// option) any later version.

// Translation of pcgen.cdom.facet.NoteItemFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/core/note_item.dart';
import 'base/abstract_list_facet.dart';

/// Tracks the [NoteItem] objects that have been added to a Player Character.
class NoteItemFacet extends AbstractListFacet<CharID, NoteItem> {}
