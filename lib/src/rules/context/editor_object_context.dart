import '../../cdom/base/cdom_object.dart';
import 'object_commit_strategy.dart';
import 'runtime_object_context.dart';

// stub: TrackingObjectCommitStrategy not yet translated
class TrackingObjectCommitStrategy implements ObjectCommitStrategy {
  void purge(CDOMObject cdo) {
    // stub
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString()); // stub
}

class EditorObjectContext extends AbstractObjectContext {
  final TrackingObjectCommitStrategy _commit = TrackingObjectCommitStrategy();

  void purge(CDOMObject cdo) {
    _commit.purge(cdo);
  }

  @override
  ObjectCommitStrategy getCommitStrategy() => _commit;
}
