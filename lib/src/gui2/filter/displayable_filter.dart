// Translation of pcgen.gui2.filter.DisplayableFilter

import 'filter.dart';

/// A filter that has a display name and description.
abstract class DisplayableFilter<T> implements Filter<T> {
  String getDisplayName();
  String? getDescription();
}
