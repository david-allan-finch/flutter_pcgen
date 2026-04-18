import '../../core/player_character.dart';

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
