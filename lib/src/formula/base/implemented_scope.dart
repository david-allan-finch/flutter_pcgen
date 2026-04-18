abstract interface class ImplementedScope {
  bool isGlobal();
  String getName();
  List<ImplementedScope> drawsFrom();
}
