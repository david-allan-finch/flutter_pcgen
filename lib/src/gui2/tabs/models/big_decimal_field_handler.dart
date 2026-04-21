// Translation of pcgen.gui2.tabs.models.BigDecimalFieldHandler

import 'formatted_field_handler.dart';

/// Formatted field handler for decimal number values (maps to Java BigDecimal).
abstract class BigDecimalFieldHandler extends FormattedFieldHandler<double> {
  @override
  double? parse(String text) => double.tryParse(text.replaceAll(',', ''));

  @override
  String format(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }
}
