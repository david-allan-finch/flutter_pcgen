//
// Copyright (c) Thomas Parker, 2018-9.
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
// Translation of pcgen.output.channel.compat.HeightCompat

import 'abstract_adapter.dart';

/// HeightCompat provides a writeable reference for the character's height channel.
class HeightCompat extends AbstractAdapter<int> {
  HeightCompat(String charId, String variableName)
      : super(charId, variableName);

  @override
  int? get() => null; // TODO: read from channel

  @override
  void set(int value) {} // TODO: write to channel
}
