// Translation of pcgen.output.actor.IsVisibleToActor

import '../base/output_actor.dart';

/// OutputActor that checks whether an object is visible for a given view.
class IsVisibleToActor implements OutputActor<dynamic> {
  final dynamic _view;

  IsVisibleToActor(this._view);

  @override
  dynamic process(String charId, dynamic obj) {
    final visibility = obj?.getSafe(/* ObjectKey.visibility */ null);
    if (visibility == null) return false;
    return visibility.isVisibleTo(_view);
  }
}
