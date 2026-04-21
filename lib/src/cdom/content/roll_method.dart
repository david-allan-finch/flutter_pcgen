//
// Copyright 2010 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.content.RollMethod
import '../base/loadable.dart';

// Defines a dice roll method for character creation (e.g., "4d6 drop lowest").
class RollMethod implements Loadable {
  String? _sourceURI;
  String? _methodName;
  String? _rollMethod;
  String? _sortKey;

  @override
  String? getSourceURI() => _sourceURI;

  @override
  void setSourceURI(String? source) { _sourceURI = source; }

  @override
  void setName(String name) { _methodName = name; }

  @override
  String? getDisplayName() => _methodName;

  @override
  String? getKeyName() => _methodName;

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;

  void setMethodRoll(String method) { _rollMethod = method; }
  String? getMethodRoll() => _rollMethod;

  void setSortKey(String sortKey) { _sortKey = sortKey; }
  String? getSortKey() => _sortKey;
}
