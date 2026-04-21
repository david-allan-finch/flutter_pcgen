//
// Copyright 2002 (C) Greg Bingleman (byngl@hotmail.com)
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
// Translation of pcgen.core.PCAlignment
import '../cdom/enumeration/string_key.dart';
import 'pcobject.dart';

// Represents an Alignment (LG, NG, CG, LN, TN, CN, LE, NE, CE).
final class PCAlignment extends PObject {
  String? getSortKey() => get(StringKey.sortKey);
}
