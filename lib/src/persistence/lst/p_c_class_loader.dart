//
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
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
// Translation of pcgen.persistence.lst.PCClassLoader

import '../../core/pc_class.dart';
import '../../core/sub_class.dart';
import '../../core/substitution_class.dart';
import '../../rules/context/load_context.dart';
import 'lst_object_file_loader.dart';
import 'source_entry.dart';

/// Loads PCClass (and SubClass / SubstitutionClass) objects from LST files.
///
/// In Java, PCClassLoader extends LstObjectFileLoader<PCClass>. The first
/// column of each line is "ClassName" for a new class, "ClassName.SUBCLASS"
/// for a sub-class header, "ClassName  <level>" for a class level definition,
/// etc. This Dart version provides the outer parse loop and dispatches to
/// helpers for the complex class-level logic.
class PCClassLoader extends LstObjectFileLoader<PCClass> {
  @override
  PCClass? parseLine(
      LoadContext context, PCClass? target, String lstLine, SourceEntry source) {
    final fields = lstLine.split('\t');
    if (fields.isEmpty) return target;

    final firstToken = fields[0].trim();
    if (firstToken.isEmpty) return target;

    final restOfLine = fields.sublist(1).join('\t');

    // Sub-class definition
    if (firstToken.endsWith('.SUBCLASS')) {
      if (target == null) return null;
      final scName = firstToken.substring(0, firstToken.length - 9);
      SubClass? sc = target.getSubClassKeyed(scName);
      if (sc == null) {
        sc = SubClass();
        sc.setName(scName);
        sc.setSourceURI(source.getURI().toString());
        target.addSubClass(sc);
      }
      _parseLineIntoClass(context, sc, source, restOfLine);
      return null;
    }

    // SubstitutionClass definition
    if (firstToken.endsWith('.SUBSTITUTIONCLASS')) {
      if (target == null) return null;
      final scName = firstToken.substring(0, firstToken.length - 18);
      SubstitutionClass? sc = target.getSubstitutionClassKeyed(scName);
      if (sc == null) {
        sc = SubstitutionClass();
        sc.setName(scName);
        sc.setSourceURI(source.getURI().toString());
        target.addSubstitutionClass(sc);
      }
      _parseLineIntoClass(context, sc, source, restOfLine);
      return null;
    }

    // Class-level definition: "ClassName    <level>" (tab-separated)
    // The level is an integer; this line applies to a specific PCClassLevel.
    // In the full implementation this would check firstToken for a level number
    // and apply to the PCClassLevel. For now we apply to the class as a whole.

    // New class or .MOD handled by parent
    PCClass pcClass = target ?? PCClass();
    if (target == null) {
      pcClass.setName(firstToken);
      pcClass.setSourceURI(source.getURI().toString());
      context.getReferenceContext().register(pcClass);
    }

    _parseLineIntoClass(context, pcClass, source, restOfLine);
    return null;
  }

  void _parseLineIntoClass(
      LoadContext context, PCClass pcClass, SourceEntry source, String restOfLine) {
    if (restOfLine.isEmpty) return;
    final tokens = restOfLine.split('\t');
    for (final token in tokens) {
      final tok = token.trim();
      if (tok.isEmpty) continue;
      // TODO: dispatch via TokenStore — full implementation uses PCClassLoader.parseToken
    }
  }

  @override
  PCClass? getObjectKeyed(LoadContext context, String key) {
    return context.getReferenceContext()
        .getAllConstructed<PCClass>(PCClass)
        .cast<PCClass?>()
        .firstWhere((c) => c?.getKeyName() == key, orElse: () => null);
  }
}
