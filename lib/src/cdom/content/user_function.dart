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
// Translation of pcgen.cdom.content.UserFunction
import 'package:flutter_pcgen/src/cdom/content/user_content.dart';

// A UserFunction is a custom formula function defined in data. It stores the
// original expression string for unparse and provides the parsed function to
// the formula system.
class UserFunction extends UserContent {
  String? _origExpression;
  dynamic _function; // FormulaFunction — typed loosely to avoid deep imports

  @override
  String getDisplayName() => getKeyName();

  void setFunction(String expression) {
    _origExpression = expression;
    // Parsing is deferred to the formula engine when registered.
    // Store expression for later registration.
    _function = expression;
  }

  String? getOriginalExpression() => _origExpression;

  dynamic getFunction() => _function;
}
