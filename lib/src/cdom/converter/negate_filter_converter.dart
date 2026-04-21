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
// Translation of pcgen.cdom.converter.NegateFilterConverter
import '../../core/player_character.dart';

// A Converter that negates (inverts) a PrimitiveFilter during conversion.
class NegateFilterConverter<B, R> {
  final dynamic _converter; // Converter<B, R>

  NegateFilterConverter(dynamic conv) : _converter = conv;

  List<R> convert(dynamic orig) =>
      _converter.convert(orig, _preventFilter) as List<R>;

  List<R> convertWithFilter(dynamic orig, dynamic lim) =>
      _converter.convert(orig, _InvertingFilter(lim)) as List<R>;

  static final _preventFilter = _PreventFilter();

  @override
  int get hashCode => _converter.hashCode;

  @override
  bool operator ==(Object obj) =>
      obj is NegateFilterConverter && obj._converter == _converter;
}

class _PreventFilter<T> {
  bool allow(PlayerCharacter pc, T obj) => false;
}

class _InvertingFilter<T> {
  final dynamic _filter;
  _InvertingFilter(this._filter);
  bool allow(PlayerCharacter pc, T obj) => !(_filter.allow(pc, obj) as bool);
}
