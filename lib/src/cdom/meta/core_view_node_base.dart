// Base class for nodes representing objects stored in a facet.
abstract class CoreViewNodeBase {
  final List<CoreViewNodeBase> _grantedByList = [];

  List<CoreViewNodeBase> getGrantedByNodes() => _grantedByList;

  void addGrantedByNode(CoreViewNodeBase node) {
    _grantedByList.add(node);
  }
}
