class NumberUtilities {
  NumberUtilities._();

  static num? toNumber(String value) {
    return num.tryParse(value);
  }

  static bool isInteger(num value) => value is int || value == value.truncate();

  static int getInt(num value) => value.toInt();

  static double getDouble(num value) => value.toDouble();
}
