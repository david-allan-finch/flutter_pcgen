//
// Copyright (c) 2009 Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.gui2.converter.Loader

import 'conversion_decider.dart';

/// Interface implemented by each LST file loader that knows how to process
/// a particular type of game-data file during dataset conversion.
abstract class Loader {
  /// Processes a single line from an LST file.
  ///
  /// [sb] accumulates the converted output for this line.
  /// [line] is the 0-based line index within the file.
  /// [lineString] is the raw text of the line.
  /// [decider] is used when user input is required for an ambiguous token.
  ///
  /// Returns a list of additional CDOMObjects that need to be injected into
  /// the output campaign, or null if none.
  List<dynamic>? process(
    StringBuffer sb,
    int line,
    String lineString,
    ConversionDecider decider,
  );

  /// Returns the list of source-entry files for this loader within [campaign].
  List<dynamic> getFiles(dynamic campaign);
}
