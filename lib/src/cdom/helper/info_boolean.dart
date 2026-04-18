// Holds an INFO token name paired with a Boolean formula.
class InfoBoolean {
  final String _infoName;
  final dynamic _formula; // NEPFormula<Boolean>

  InfoBoolean(String infoName, dynamic formula)
      : _infoName = infoName,
        _formula = formula;

  String getInfoName() => _infoName;
  dynamic getFormula() => _formula;
}
