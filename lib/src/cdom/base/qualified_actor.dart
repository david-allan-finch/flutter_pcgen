import 'qualifying_object.dart';

// Functional interface for acting on a QualifyingObject with a source.
abstract interface class QualifiedActor<T extends QualifyingObject, R> {
  R act(T object, Object source);
}
