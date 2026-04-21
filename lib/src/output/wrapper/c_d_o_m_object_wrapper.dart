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
// Translation of pcgen.output.wrapper.CDOMObjectWrapper

import '../base/p_c_gen_object_wrapper.dart';
import '../model/c_d_o_m_object_model.dart';

/// Wraps CDOMObject objects into output models using a CharID.
class CDOMObjectWrapper implements PCGenObjectWrapper {
  @override
  dynamic wrap(String charId, Object obj) {
    // TODO: look up OutputActor map from CDOMWrapperInfoFacet
    return CDOMObjectModel(charId, obj, const {});
  }
}
