import '../cdom/base/loadable.dart';

// Represents a measurement unit set (e.g. Imperial or Metric) from game mode.
// Handles conversion and display formatting for distance, height, and weight.
final class UnitSet implements Loadable {
  String? _distanceUnit;
  String? _heightUnit;
  String? _weightUnit;
  String? _name;
  double _distanceFactor = 1.0;
  double _heightFactor = 1.0;
  double _weightFactor = 1.0;
  String _distancePattern = '0.##';
  String _heightPattern = '0.##';
  String _weightPattern = '0.##';
  bool _isInternal = false;
  String? _sourceUri;

  void setDistanceFactor(double df) => _distanceFactor = df;
  void setHeightFactor(double hf) => _heightFactor = hf;
  void setWeightFactor(double wf) => _weightFactor = wf;

  void setDistanceUnit(String du) => _distanceUnit = du;
  void setHeightUnit(String hu) => _heightUnit = hu;
  void setWeightUnit(String wu) => _weightUnit = wu;

  void setDistanceDisplayPattern(String p) => _distancePattern = p;
  void setHeightDisplayPattern(String p) => _heightPattern = p;
  void setWeightDisplayPattern(String p) => _weightPattern = p;

  String getDistanceUnit() => _getUnit(_distanceUnit ?? '');
  String getHeightUnit() => _getUnit(_heightUnit ?? '');
  String getWeightUnit() => _getUnit(_weightUnit ?? '');

  String getRawDistanceUnit() => _distanceUnit ?? '';
  String getRawHeightUnit() => _heightUnit ?? '';
  String getRawWeightUnit() => _weightUnit ?? '';

  String getDistanceDisplayPattern() => _distancePattern;
  String getHeightDisplayPattern() => _heightPattern;
  String getWeightDisplayPattern() => _weightPattern;
  double getDistanceFactor() => _distanceFactor;
  double getHeightFactor() => _heightFactor;
  double getWeightFactor() => _weightFactor;

  String _getUnit(String unitString) {
    if (unitString == 'ftin') return unitString;
    if (unitString.startsWith('~')) return unitString.substring(1);
    return ' $unitString';
  }

  double convertDistanceToUnitSet(double distanceInFeet) =>
      distanceInFeet * _distanceFactor;

  int convertHeightFromUnitSet(double height) =>
      (height / _heightFactor).toInt();

  double convertHeightToUnitSet(double heightInInches) =>
      heightInInches * _heightFactor;

  double convertWeightFromUnitSet(double weight) => weight / _weightFactor;

  double convertWeightToUnitSet(double weightInPounds) =>
      weightInPounds * _weightFactor;

  int convertWeightToUnitSetInt(int weightInPounds) =>
      (weightInPounds * _weightFactor).toInt();

  String displayDistanceInUnitSet(double distanceInFeet) =>
      convertDistanceToUnitSet(distanceInFeet).toStringAsFixed(2);

  String displayHeightInUnitSet(int heightInInches) =>
      convertHeightToUnitSet(heightInInches.toDouble()).toStringAsFixed(2);

  String displayWeightInUnitSet(double weightInPounds) =>
      convertWeightToUnitSet(weightInPounds).toStringAsFixed(2);

  @override
  String? getSourceURI() => _sourceUri;

  @override
  void setSourceURI(String source) => _sourceUri = source;

  @override
  void setName(String n) => _name = n;

  @override
  String getDisplayName() => _name ?? '';

  @override
  String getKeyName() => _name ?? '';

  @override
  bool isInternal() => _isInternal;

  void setInternal(bool internal) => _isInternal = internal;

  @override
  bool isType(String type) => false;
}
