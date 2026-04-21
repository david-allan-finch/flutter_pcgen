// Translation of pcgen.gui2.util.SortableModel

import 'table/row.dart';

/// A model that can be sorted by a supplied [Comparator] over [Row] objects.
abstract interface class SortableModel {
  void sortModel(Comparator<Row> comparator);
}
