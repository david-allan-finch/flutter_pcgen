import 'category.dart';
import 'chooser.dart';

// CategorizedChooser extends Chooser to additionally allow decoding with
// an explicit Category context.
abstract interface class CategorizedChooser<T> implements Chooser<T> {
  T decodeChoiceWithCategory(dynamic context, String persistentFormat, Category<dynamic> category);
}
