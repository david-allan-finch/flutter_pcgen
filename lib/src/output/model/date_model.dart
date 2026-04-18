// Translation of pcgen.output.model.DateModel

/// Output model wrapping a DateTime value.
class DateModel {
  final DateTime _date;
  DateModel(this._date);
  @override
  String toString() => _date.toIso8601String();
}
