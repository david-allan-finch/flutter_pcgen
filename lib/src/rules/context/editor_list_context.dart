//
// Missing License Header, Copyright 2016 (C) Andrew Maitland <amaitland@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.rules.context.EditorListContext
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
