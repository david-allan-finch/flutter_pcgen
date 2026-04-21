//
// Copyright (c) 2009 Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.gui2.converter.loader.CopyLoader

import 'package:flutter_pcgen/src/gui2/converter/conversion_decider.dart';
import 'package:flutter_pcgen/src/gui2/converter/loader.dart';

/// A [Loader] that copies each line verbatim without any token conversion.
/// Used for file types that do not require data transformation.
class CopyLoader implements Loader {
  /// The list-key under which files are stored on a Campaign.
  final dynamic listKey;

  CopyLoader(this.listKey);

  @override
  List<dynamic>? process(
    StringBuffer sb,
    int line,
    String lineString,
    ConversionDecider decider,
  ) {
    sb.write(lineString);
    return null;
  }

  @override
  List<dynamic> getFiles(dynamic campaign) {
    return campaign.getSafeListFor(listKey) as List<dynamic>;
  }
}
