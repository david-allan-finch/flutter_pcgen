//
// Copyright 2017 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under the terms
// of the GNU Lesser General Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along with
// this library; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
// Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.output.actor.IsVisibleToActor

import 'package:flutter_pcgen/src/output/base/output_actor.dart';

/// OutputActor that checks whether an object is visible for a given view.
class IsVisibleToActor implements OutputActor<dynamic> {
  final dynamic _view;

  IsVisibleToActor(this._view);

  @override
  dynamic process(String charId, dynamic obj) {
    final visibility = obj?.getSafeObject(ObjectKey.getConstant('VISIBILITY'));
    if (visibility == null) return false;
    return visibility.isVisibleTo(_view);
  }
}
