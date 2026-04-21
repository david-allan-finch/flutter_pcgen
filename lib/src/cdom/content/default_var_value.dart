//
// Copyright 2015 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.content.DefaultVarValue
import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'package:flutter_pcgen/src/base/util/indirect.dart';
import 'user_content.dart';

// DefaultVarValue is a shell object used during LST loading to carry the
// default value definition for a variable format. Values are not used at
// runtime; they are consumed by the token/loader system.
class DefaultVarValue extends UserContent {
  FormatManager<dynamic>? _formatManager;
  Indirect<dynamic>? _indirect;

  @override
  String getDisplayName() => getKeyName();

  void setFormatManager(FormatManager<dynamic> fmtManager) =>
      _formatManager = fmtManager;

  FormatManager<dynamic>? getFormatManager() => _formatManager;

  void setIndirect(Indirect<dynamic> indirect) => _indirect = indirect;

  Indirect<dynamic>? getIndirect() => _indirect;
}
