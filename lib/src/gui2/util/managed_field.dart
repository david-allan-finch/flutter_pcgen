//
// Copyright (c) 2018 Tom Parker <thpr@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under the terms
// of the GNU Lesser General Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along with
// this library; if not, write to the Free Software Foundation, Inc., 51 Franklin Street,
// Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.gui2.util.ManagedField

import 'package:flutter/material.dart';

import 'installable.dart';

/// A [ManagedField] manages a [TextEditingController] (Dart equivalent of
/// JTextField) and is [Installable] — i.e. it can be connected to / disconnected
/// from a PlayerCharacter.
abstract interface class ManagedField implements Installable {
  /// Returns the [TextEditingController] that this [ManagedField] manages.
  TextEditingController getTextField();
}
