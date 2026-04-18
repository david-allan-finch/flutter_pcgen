import 'object_commit_strategy.dart';

// stub: AbstractObjectContext and ConsolidatedObjectCommitStrategy not yet translated
abstract class AbstractObjectContext {
  ObjectCommitStrategy getCommitStrategy();
}

// stub: full implementation deferred (ConsolidatedObjectCommitStrategy not translated)
class ConsolidatedObjectCommitStrategy implements ObjectCommitStrategy {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString()); // stub
}

class RuntimeObjectContext extends AbstractObjectContext {
  final ConsolidatedObjectCommitStrategy commit =
      ConsolidatedObjectCommitStrategy();

  @override
  ObjectCommitStrategy getCommitStrategy() => commit;
}
