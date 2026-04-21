//
// Copyright 2014 (C) Tom Parker <thpr@users.sourceforge.net>
// Copyright James Dempsey, 2012
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
// Translation of pcgen.cdom.base.CategorizedChooser
import 'package:flutter_pcgen/src/cdom/base/category.dart';
import 'package:flutter_pcgen/src/cdom/base/chooser.dart';

// CategorizedChooser extends Chooser to additionally allow decoding with
// an explicit Category context.
abstract interface class CategorizedChooser<T> implements Chooser<T> {
  T decodeChoiceWithCategory(dynamic context, String persistentFormat, Category<dynamic> category);
}
