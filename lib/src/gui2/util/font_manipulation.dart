//
// Copyright 2013 (C) Vincent Lhote
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
// Translation of pcgen.gui2.util.FontManipulation

import 'package:flutter/material.dart';

/// Utility class for font manipulation, providing CSS-style relative sizing.
/// Font sizes are expressed as multipliers of the base font size.
/// Bold/italic variants are also provided.
final class FontManipulation {
  FontManipulation._();

  /// Returns a bold version of [style] (used for titles).
  static TextStyle title(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.bold);
  }

  /// Returns an xx-large version of [style] (×1.5 size).
  static TextStyle xxlarge(TextStyle style) {
    final size = style.fontSize ?? 14.0;
    return style.copyWith(fontSize: size * 1.5);
  }

  /// Returns a large version of [style] (×1.167 size).
  static TextStyle large(TextStyle style) {
    final size = style.fontSize ?? 14.0;
    return style.copyWith(fontSize: size * 1.167);
  }

  /// Returns a small version of [style] (×0.917 size).
  static TextStyle small(TextStyle style) {
    final size = style.fontSize ?? 14.0;
    return style.copyWith(fontSize: size * 0.917);
  }

  /// Returns an x-small version of [style] (×0.833 size).
  static TextStyle xsmall(TextStyle style) {
    final size = style.fontSize ?? 14.0;
    return style.copyWith(fontSize: size * 0.833);
  }

  /// Returns an italic version of [style] (for less-important text).
  static TextStyle less(TextStyle style) {
    return style.copyWith(fontStyle: FontStyle.italic);
  }

  /// Returns a plain (normal weight, non-italic) version of [style].
  static TextStyle plain(TextStyle style) {
    return style.copyWith(
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
    );
  }

  /// Returns a bold version of [style].
  static TextStyle bold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.bold);
  }

  /// Returns a bold-italic version of [style].
  static TextStyle boldItalic(TextStyle style) {
    return style.copyWith(
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic,
    );
  }
}
