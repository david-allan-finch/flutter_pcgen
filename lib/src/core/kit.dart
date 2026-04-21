//
// Copyright 2001 (C) Greg Bingleman <byngl@hotmail.com>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.Kit
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'package:flutter_pcgen/src/core/pcobject.dart';

// Represents a starting kit for character creation.
final class Kit extends PObject {
  int _region = 0;

  int getRegion() => _region;

  String getDescription() => getSafeString(StringKey.description);

  List<dynamic> getKitTasks() =>
      getSafeListFor<dynamic>(ListKey.getConstant<dynamic>('KIT_TASKS'));

  @override
  String toString() => getDisplayName();
}
