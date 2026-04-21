//
// Copyright (c) 2006, 2009.
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
// Translation of pcgen.gui2.converter.event.TokenProcessorPlugin

import 'package:flutter_pcgen/src/gui2/converter/event/token_processor.dart';

/// Extension of [TokenProcessor] that additionally declares which CDOMObject
/// class and token name it handles.  Implementations are discovered and
/// registered via [TokenConverter.addToTokenMap].
abstract class TokenProcessorPlugin extends TokenProcessor {
  /// Returns the [Type] of the CDOMObject subclass this plugin handles.
  Type getProcessedClass();

  /// Returns the token key string (e.g. "ABILITY") this plugin handles.
  String getProcessedToken();
}
