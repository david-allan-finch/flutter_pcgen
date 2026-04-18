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
