// Copyright (c) Thomas Parker, 2012.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

// Translation of pcgen.cdom.facet.TemplateSelectionFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_association_facet.dart';

/// Tracks PCTemplates of a Player Character with the CHOOSE selection that was
/// made (if CHOOSE was present). PCTemplate is typed as [dynamic].
class TemplateSelectionFacet extends AbstractAssociationFacet<CharID, dynamic, dynamic> {}
