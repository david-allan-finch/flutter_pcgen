// Translation of pcgen.system.LoggingRecorder

/// Records log messages to a file.
class LoggingRecorder {
  final String logFilePath;
  final List<String> _records = [];

  LoggingRecorder(this.logFilePath);

  void publish(String record) => _records.add(record);

  List<String> getRecords() => List.unmodifiable(_records);

  void close() => _records.clear();
}
