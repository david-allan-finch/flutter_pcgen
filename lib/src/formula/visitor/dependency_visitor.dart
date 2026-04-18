import '../parse/node.dart';
import '../base/dependency_manager.dart';

abstract interface class DependencyVisitor {
  Object? visit(Node node, DependencyManager manager);
}
