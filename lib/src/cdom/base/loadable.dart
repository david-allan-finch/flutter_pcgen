import 'identified.dart';

// An object that PCGen can load from LST file storage.
abstract interface class Loadable implements Identified {
  void setName(String name);
  String? getSourceURI();
  void setSourceURI(String? source);
  bool isInternal();
  bool isType(String type);
}
