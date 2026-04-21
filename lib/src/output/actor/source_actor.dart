//
// Copyright 2014-15 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.output.actor.SourceActor

import 'package:flutter_pcgen/src/output/base/output_actor.dart';

/// OutputActor that returns source information (e.g. book/page) of an object.
class SourceActor implements OutputActor<dynamic> {
  final String _sourceType; // e.g. 'SHORT', 'LONG', 'PAGE', 'WEB'

  SourceActor(this._sourceType);

  @override
  dynamic process(String charId, dynamic obj) {
    switch (_sourceType.toUpperCase()) {
      case 'SHORT':
        return obj?.getSourceShort(8) ?? '';
      case 'LONG':
        return obj?.getSourceMap()['SOURCELONG'] ?? '';
      case 'PAGE':
        return obj?.getSourceMap()['SOURCEPAGE'] ?? '';
      case 'WEB':
        return obj?.getSourceMap()['SOURCEWEB'] ?? '';
      default:
        return obj?.getSource() ?? '';
    }
  }
}
