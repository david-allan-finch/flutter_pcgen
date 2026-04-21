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
// Translation of pcgen.cdom.content.UserContent
import '../../base/util/format_manager.dart';
import '../base/loadable.dart';

// Abstract base for user-defined content items (variables, functions, facts).
abstract class UserContent implements Loadable {
  String? _name;
  String? _sourceUri;
  String? _explanation;

  @override
  void setName(String name) => _name = name;

  @override
  String getKeyName() => _name ?? '';

  @override
  void setSourceURI(String source) => _sourceUri = source;

  @override
  String? getSourceURI() => _sourceUri;

  void setExplanation(String value) => _explanation = value;

  String? getExplanation() => _explanation;

  String getDisplayName();

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;
}
