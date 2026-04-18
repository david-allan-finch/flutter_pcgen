import 'indirect.dart';
import 'object_container.dart';

abstract interface class ReferenceConverter<T> {
  T convert(String inputStr);
  Indirect<T> convertIndirect(String inputStr);
  ObjectContainer<T> convertObjectContainer(String inputStr);
  String unconvert(T obj);
  Type getManagedClass();
}
