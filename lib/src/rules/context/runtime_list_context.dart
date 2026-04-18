import 'list_commit_strategy.dart';

// stub: AbstractListContext not yet translated; RuntimeListContext holds commit strategy
abstract class AbstractListContext {
  ListCommitStrategy getCommitStrategy();
}

class RuntimeListContext extends AbstractListContext {
  final ListCommitStrategy _commit;

  RuntimeListContext(ListCommitStrategy commitStrategy)
      : _commit = commitStrategy {
    ArgumentError.checkNotNull(commitStrategy, 'commitStrategy');
  }

  @override
  ListCommitStrategy getCommitStrategy() => _commit;
}
