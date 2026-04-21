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
// Translation of pcgen.cdom.content.BaseDice
import '../../core/roll_info.dart';
import '../base/loadable.dart';

// Defines how a die type changes as size adjustments are applied.
class BaseDice implements Loadable {
  String? _sourceURI;
  String? _dieName;
  final List<RollInfo> _downList = [];
  final List<RollInfo> _upList = [];

  @override
  String? getSourceURI() => _sourceURI;

  @override
  void setSourceURI(String? source) { _sourceURI = source; }

  @override
  void setName(String name) { _dieName = name; }

  @override
  String? getDisplayName() => _dieName;

  @override
  String? getKeyName() => _dieName;

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;

  void addToDownList(RollInfo rollInfo) { _downList.add(rollInfo); }
  void addToUpList(RollInfo rollInfo) { _upList.add(rollInfo); }

  List<RollInfo> getUpSteps() => List.unmodifiable(_upList);
  List<RollInfo> getDownSteps() => List.unmodifiable(_downList);
}
