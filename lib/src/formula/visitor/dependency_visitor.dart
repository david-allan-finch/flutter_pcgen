import 'package:flutter_pcgen/src/formula/parse/node.dart';
import 'package:flutter_pcgen/src/formula/base/dependency_manager.dart';

abstract interface class DependencyVisitor {
  Object? visit(Node node, DependencyManager manager);
}
