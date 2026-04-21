//
// Copyright (c) 2008 Tom Parker <thpr@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.cdom.helper.AbstractSimpleProfProvider
import '../base/cdom_object.dart';
import 'prof_provider.dart';

// An AbstractSimpleProfProvider grants proficiency based on a single
// proficiency object. It never grants proficiency by Equipment TYPE and
// always qualifies (it never contains prerequisites).
abstract class AbstractSimpleProfProvider<T extends CDOMObject>
    implements ProfProvider<T> {
  final T _prof;

  AbstractSimpleProfProvider(T proficiency) : _prof = proficiency;

  // Returns true only if the given proficiency equals the stored one.
  @override
  bool providesProficiency(T proficiency) => _prof == proficiency;

  // Always returns true; this provider has no prerequisites.
  @override
  bool qualifies(dynamic playerCharacter, Object? owner) => true;

  // Always returns false; this provider never grants type-based proficiency.
  @override
  bool providesEquipmentType(String type) => false;

  // Returns the key name of the single proficiency as the LST format.
  @override
  String getLstFormat() => _prof.getKeyName() ?? '';

  // Returns true if both providers hold the same underlying proficiency.
  bool hasSameProf(AbstractSimpleProfProvider<T> aspp) =>
      _prof == aspp._prof;
}
