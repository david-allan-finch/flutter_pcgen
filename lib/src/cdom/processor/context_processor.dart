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
// Translation of pcgen.cdom.processor.ContextProcessor
import 'package:flutter_pcgen/src/cdom/content/processor.dart';

// A Processor that conditionally applies an underlying Processor based on context.
class ContextProcessor<T, R> implements Processor<T> {
  final Processor<T> _processor;
  final dynamic _contextItems; // CDOMReference<R>

  ContextProcessor(Processor<T> mod, dynamic contextRef)
      : _processor = mod,
        _contextItems = contextRef;

  @override
  T applyProcessor(T input, Object? context) {
    if (context != null && _contextItems.contains(context)) {
      return _processor.applyProcessor(input, context);
    }
    return input;
  }

  @override
  String getLSTformat() =>
      '${_contextItems.getLSTformat()}|${_processor.getLSTformat()}';

  @override
  Type getModifiedClass() => _processor.getModifiedClass();

  @override
  int get hashCode => _processor.hashCode * 29 + _contextItems.hashCode;

  @override
  bool operator ==(Object obj) =>
      obj is ContextProcessor &&
      obj._processor == _processor &&
      obj._contextItems == _contextItems;
}
