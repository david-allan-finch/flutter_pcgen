//
// Copyright 2018 (C) Tom Parker <thpr@sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under the terms
// of the GNU Lesser General Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along with
// this library; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
// Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.output.channel.compat.HairColorCompat

import 'package:flutter_pcgen/src/output/compat/abstract_adapter.dart';

/// HairColorCompat provides a writeable reference for the character's hair color channel.
class HairColorCompat extends AbstractAdapter<String> {
  HairColorCompat(String charId, String variableName)
      : super(charId, variableName);

  @override
  String? get() => null; // TODO: read from channel

  @override
  void set(String value) {} // TODO: write to channel
}
