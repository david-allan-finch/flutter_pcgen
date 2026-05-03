//
// Copyright 2002 (C) Bryan McRoberts <merton_monk@yahoo.com>
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
// Translation of pcgen.core.SubClass
import 'package:flutter_pcgen/src/cdom/base/categorized.dart';
import 'package:flutter_pcgen/src/cdom/base/category.dart';
import 'package:flutter_pcgen/src/cdom/base/loadable.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/integer_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';

// A specialized variant of a PCClass with modified spell prohibition and cost.
final class SubClass extends PCClass implements Categorized<SubClass> {
  String getChoice() {
    final sp = getObject(CDOMObjectKey.choice);
    if (sp == null) return '';
    // SpellProhibitor value list — simplified
    return sp.toString();
  }

  int getProhibitCost() {
    final prohib = getInt(IntegerKey.prohibitCost);
    if (prohib != null) return prohib;
    return getSafeInt(IntegerKey.cost);
  }

  @override
  Category<SubClass> getCDOMCategory() {
    return getObject(CDOMObjectKey.subclassCategory) as Category<SubClass>;
  }

  @override
  void setCDOMCategory(Category<SubClass> cat) {
    putObject(CDOMObjectKey.subclassCategory, cat);
  }

  @override
  ClassIdentity<Loadable> getClassIdentity() => getCDOMCategory()!;

  @override
  String getFullKey() => '${getCDOMCategory()}.${super.getFullKey()}';
}
