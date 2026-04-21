//
// Copyright 2019 Thomas Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.gui2.tabs.models.ChannelHandler

import 'package:flutter/foundation.dart';

/// Bridges a character facade "channel" (a VariableChannel) to a Flutter
/// ChangeNotifier so UI can observe and write back to the model.
class ChannelHandler<T> extends ChangeNotifier {
  T? _value;
  final T? Function(dynamic character) _reader;
  final void Function(dynamic character, T value)? _writer;

  ChannelHandler({
    required T? Function(dynamic character) reader,
    void Function(dynamic character, T value)? writer,
  })  : _reader = reader,
        _writer = writer;

  T? get value => _value;

  set value(T? v) {
    if (_value == v) return;
    _value = v;
    notifyListeners();
  }

  void install(dynamic character) {
    _value = _reader(character);
    notifyListeners();
  }

  void commit(dynamic character) {
    if (_value != null) _writer?.call(character, _value as T);
  }
}
