import 'primitive_filter.dart';

// Converter transforms an ObjectContainer of B into a collection of R,
// optionally filtered by a PrimitiveFilter.
abstract interface class Converter<B, R> {
  List<R> convert(dynamic orig);
  List<R> convertWithFilter(dynamic orig, PrimitiveFilter<B> lim);
}
