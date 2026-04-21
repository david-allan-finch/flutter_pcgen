//
// Copyright 2014 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.content.DatasetVariable
import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'user_content.dart';

// A DatasetVariable is a variable in the formula system defined by data.
// Legal names must start with a letter followed by word characters only.
class DatasetVariable extends UserContent {
  static final _legalPattern = RegExp(r'^[A-Za-z]\w*$');

  FormatManager<dynamic>? _format;
  dynamic _scope; // PCGenScope — typed loosely to avoid circular imports

  @override
  String getDisplayName() => getKeyName();

  void setScope(dynamic scope) {
    if (scope == null) return;
    _scope = scope;
  }

  dynamic getScope() => _scope;

  static bool isLegalName(String proposedName) =>
      _legalPattern.hasMatch(proposedName);

  FormatManager<dynamic>? getFormat() => _format;

  void setFormat(FormatManager<dynamic> format) => _format = format;
}
