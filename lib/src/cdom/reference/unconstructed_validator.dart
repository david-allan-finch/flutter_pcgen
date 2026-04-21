//
// Copyright 2009 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.reference.UnconstructedValidator
import '../base/class_identity.dart';

// Indicates what behaviors are allowed for a given class/ClassIdentity,
// such as unconstructed references and duplicates.
abstract interface class UnconstructedValidator {
  // Returns true if the given class allows duplicate objects to exist.
  bool allowDuplicates(Type objClass);

  // Returns true if the given key for the given ClassIdentity is allowed to
  // remain unconstructed.
  bool allowUnconstructed(ClassIdentity<dynamic> identity, String key);
}
