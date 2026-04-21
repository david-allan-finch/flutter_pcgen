import 'package:flutter_pcgen/src/base/util/indirect.dart';
import 'package:flutter_pcgen/src/base/util/object_container.dart';
import 'package:flutter_pcgen/src/base/util/value_store.dart';

abstract class FormatManager<T> {
  const FormatManager();
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
