//
// Copyright 2007, 2008 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.reference.TransparentReference
import '../base/loadable.dart';
import 'reference_manufacturer.dart';

// A TransparentReference is a CDOMReference that can be re-resolved using a
// ReferenceManufacturer. Used when a reference must be created before the
// appropriate manufacturer exists (e.g. game-mode references resolved against
// per-campaign manufacturers).
abstract interface class TransparentReference<T extends Loadable> {
  // Resolves this reference using the given manufacturer, overwriting any
  // previously resolved underlying reference.
  void resolve(ReferenceManufacturer<T> rm);
}
