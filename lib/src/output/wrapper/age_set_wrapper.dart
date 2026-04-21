//
// Copyright 2014-16 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.output.wrapper.AgeSetWrapper

import 'package:flutter_pcgen/src/output/base/simple_object_wrapper.dart';
import 'package:flutter_pcgen/src/output/model/age_set_model.dart';

/// Wraps AgeSet objects into output models.
class AgeSetWrapper implements SimpleObjectWrapper {
  @override
  dynamic wrap(Object obj) {
    // TODO: check for AgeSet type when AgeSet is defined
    return AgeSetModel(obj);
  }
}
