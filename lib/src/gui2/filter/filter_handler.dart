// Translation of pcgen.gui2.filter.FilterHandler

import 'filter.dart';

/// Interface for components that handle filter application.
abstract class FilterHandler<T> {
  void setFilter(Filter<T>? filter);
  Filter<T>? getFilter();
  void filterUpdated();
}
