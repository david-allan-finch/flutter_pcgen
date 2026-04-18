import 'indirect.dart';
import 'object_container.dart';
import 'value_store.dart';

abstract interface class FormatManager<T> {
  T convert(String inputStr);
  Indirect<T> convertIndirect(String inputStr);
  ObjectContainer<T> convertObjectContainer(String inputStr);
  String unconvert(T obj);
  Type getManagedClass();
  String getIdentifierType();
  FormatManager<dynamic>? getComponentManager();

  T initializeFrom(ValueStore valueStore) {
    return valueStore.getValueFor(getIdentifierType()) as T;
  }
}
