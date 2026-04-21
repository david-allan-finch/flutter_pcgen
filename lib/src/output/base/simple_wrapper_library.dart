//
// Copyright (c) Thomas Parker, 2016.
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
// Translation of pcgen.output.base.SimpleWrapperLibrary

import 'simple_object_wrapper.dart';
import 'package:flutter_pcgen/src/output/wrapper/string_wrapper.dart';
import 'package:flutter_pcgen/src/output/wrapper/number_wrapper.dart';
import 'package:flutter_pcgen/src/output/wrapper/boolean_wrapper.dart';
import 'package:flutter_pcgen/src/output/wrapper/type_safe_constant_wrapper.dart';
import 'package:flutter_pcgen/src/output/wrapper/category_wrapper.dart';
import 'package:flutter_pcgen/src/output/wrapper/enum_wrapper.dart';
import 'package:flutter_pcgen/src/output/wrapper/ordered_pair_wrapper.dart';
import 'package:flutter_pcgen/src/output/wrapper/age_set_wrapper.dart';

/// SimpleWrapperLibrary stores information on simple wrappers used to wrap
/// objects into output models.
final class SimpleWrapperLibrary {
  SimpleWrapperLibrary._();

  static final List<SimpleObjectWrapper> _wrapperList = [
    StringWrapper(),
    NumberWrapper(),
    BooleanWrapper(),
    TypeSafeConstantWrapper(),
    CategoryWrapper(),
    EnumWrapper(),
    OrderedPairWrapper(),
    AgeSetWrapper(),
  ];

  /// Wraps the given object using the first wrapper that succeeds.
  static dynamic wrap(Object? toWrap) {
    if (toWrap == null) return null;
    for (final ow in _wrapperList) {
      try {
        return ow.wrap(toWrap);
      } catch (_) {
        // Try next wrapper
      }
    }
    throw StateError('Unable to find wrapping for ${toWrap.runtimeType}');
  }
}
