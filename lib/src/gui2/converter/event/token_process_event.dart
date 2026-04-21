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
// Translation of pcgen.gui2.converter.event.TokenProcessEvent

import 'package:flutter_pcgen/src/gui2/converter/conversion_decider.dart';

/// Event carrying all context needed to process a single LST token during
/// data conversion.  The processor appends its output via [append] and calls
/// [consume] to signal that it handled the token.
class TokenProcessEvent {
  /// The load context (typed as dynamic to avoid hard coupling to the
  /// rules-context layer at this translation level).
  final dynamic context;

  /// The decider used when user input is required during conversion.
  final ConversionDecider decider;

  /// The token key (left-hand side of the colon in an LST token).
  final String key;

  /// The token value (right-hand side of the colon), or null if absent.
  final String? value;

  /// The display name of the object being converted.
  final String objectName;

  /// The primary CDOMObject being processed (typed as dynamic).
  final dynamic primary;

  /// The source object (mirrors EventObject.source in Java).
  final dynamic source;

  final StringBuffer _result = StringBuffer();
  bool _consumed = false;
  List<dynamic>? _injected;

  TokenProcessEvent({
    required this.context,
    required this.decider,
    required this.key,
    required this.value,
    required this.objectName,
    required this.primary,
  }) : source = primary;

  /// Marks this event as fully handled by a processor.
  void consume() => _consumed = true;

  bool isConsumed() => _consumed;

  /// Appends [s] to the output buffer.
  void appendString(String s) => _result.write(s);

  /// Appends the single character [c] to the output buffer.
  void appendChar(String c) => _result.write(c);

  /// Returns the accumulated output produced by processors.
  String getResult() => _result.toString();

  String getKey() => key;
  String? getValue() => value;
  String getObjectName() => objectName;
  dynamic getPrimary() => primary;
  dynamic getContext() => context;
  ConversionDecider getDecider() => decider;

  /// Injects an additional CDOMObject to be written to the campaign.
  void inject(dynamic cdo) {
    _injected ??= [];
    _injected!.add(cdo);
  }

  /// Returns a copy of the injected objects list, or null if none were added.
  List<dynamic>? getInjected() =>
      _injected == null ? null : List.of(_injected!);
}
