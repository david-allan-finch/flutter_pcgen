import '../../cdom/base/cdom_object.dart';
import 'list_commit_strategy.dart';
import 'runtime_list_context.dart';

// stub: TrackingListCommitStrategy not yet translated
class TrackingListCommitStrategy implements ListCommitStrategy {
  void purge(CDOMObject cdo) {
    // stub
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString()); // stub
}

class EditorListContext extends AbstractListContext {
  final TrackingListCommitStrategy _commit = TrackingListCommitStrategy();

  @override
  ListCommitStrategy getCommitStrategy() => _commit;

  void purge(CDOMObject cdo) {
    _commit.purge(cdo);
  }
}
