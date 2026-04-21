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
// Translation of pcgen.rules.persistence.token.PostValidationToken
import 'package:flutter_pcgen/src/rules/context/load_context.dart';

/// A PostValidationToken is processed after LST file load is complete and
/// after references are resolved. It operates on ALL objects of a given type.
abstract interface class PostValidationToken<T> {
  /// Process the token across all collected objects. Returns true if successful.
  bool process(LoadContext context, List<T> collection);

  /// Returns the Type of object this PostValidationToken operates on.
  Type getValidationTokenClass();

  /// Returns the priority (lower = processed first).
  int getPriority();
}
