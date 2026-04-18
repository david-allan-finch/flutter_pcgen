// Translation of pcgen.output.actor.SourceActor

import '../base/output_actor.dart';

/// OutputActor that returns source information (e.g. book/page) of an object.
class SourceActor implements OutputActor<dynamic> {
  final String _sourceType; // e.g. 'SHORT', 'LONG', 'PAGE', 'WEB'

  SourceActor(this._sourceType);

  @override
  dynamic process(String charId, dynamic obj) {
    switch (_sourceType.toUpperCase()) {
      case 'SHORT':
        return obj?.getSourceShort(8) ?? '';
      case 'LONG':
        return obj?.getSourceMap()['SOURCELONG'] ?? '';
      case 'PAGE':
        return obj?.getSourceMap()['SOURCEPAGE'] ?? '';
      case 'WEB':
        return obj?.getSourceMap()['SOURCEWEB'] ?? '';
      default:
        return obj?.getSource() ?? '';
    }
  }
}
