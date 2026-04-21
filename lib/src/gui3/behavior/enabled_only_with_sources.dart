// Translation of pcgen.gui3.behavior.EnabledOnlyWithSources

import 'package:flutter/foundation.dart';

/// A ValueNotifier<bool> that is true only when at least one source is loaded.
/// Used to enable/disable UI actions that require loaded game data.
class EnabledOnlyWithSources extends ValueNotifier<bool> {
  EnabledOnlyWithSources() : super(false);

  void onSourcesLoaded(List<dynamic> sources) {
    value = sources.isNotEmpty;
  }

  void onSourcesCleared() {
    value = false;
  }
}
