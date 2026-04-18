class CSVUtilities {
  CSVUtilities._();

  static List<String> parseCSV(String input) {
    final result = <String>[];
    final parts = input.split(',');
    for (final part in parts) {
      result.add(part.trim());
    }
    return result;
  }

  static String toCSV(Iterable<Object?> items) =>
      items.map((e) => e.toString()).join(',');
}
