import 'reference_facade.dart';

// Mutable version of ReferenceFacade.
abstract interface class WriteableReferenceFacade<E> implements ReferenceFacade<E> {
  void set(E? object);
}
