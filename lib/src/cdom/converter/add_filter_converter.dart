//
// Copyright 2010 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.converter.AddFilterConverter
import 'package:flutter_pcgen/src/core/player_character.dart';

// A Converter that adds a PrimitiveFilter to the conversion process.
class AddFilterConverter<B, R> {
  final dynamic _converter; // Converter<B, R>
  final dynamic _filter; // PrimitiveFilter<B>

  AddFilterConverter(dynamic conv, dynamic fil)
      : _converter = conv,
        _filter = fil;

  List<R> convert(dynamic orig) =>
      _converter.convert(orig, _filter) as List<R>;

  List<R> convertWithFilter(dynamic orig, dynamic lim) =>
      _converter.convert(orig, _CompoundFilter(_filter, lim)) as List<R>;

  @override
  int get hashCode => _converter.hashCode;

  @override
  bool operator ==(Object obj) =>
      obj is AddFilterConverter &&
      obj._filter == _filter &&
      obj._converter == _converter;
}

class _CompoundFilter<T> {
  final dynamic _filter1;
  final dynamic _filter2;

  _CompoundFilter(this._filter1, this._filter2);

  bool allow(PlayerCharacter pc, T obj) =>
      _filter1.allow(pc, obj) == _filter2.allow(pc, obj);
}
