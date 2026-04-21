// Translation of pcgen.gui2.converter.loader.AbilityLoader

import '../conversion_decider.dart';
import 'basic_loader.dart';

/// Extends [BasicLoader] with extra pre-processing for Ability files:
/// scans each line for a CATEGORY token and ensures the named
/// AbilityCategory is defined in the context before the base loader runs.
class AbilityLoader extends BasicLoader<dynamic> {
  AbilityLoader({
    required super.context,
    required super.listKey,
    required super.changeLogWriter,
  }) : super(cdomClass: dynamic);

  @override
  List<dynamic>? process(
    StringBuffer sb,
    int line,
    String lineString,
    ConversionDecider decider,
  ) {
    // Ensure the ability category is defined before processing tokens.
    final tokens = lineString.split(BasicLoader.fieldSeparator);
    for (final tok in tokens) {
      if (tok.startsWith('CATEGORY:')) {
        final abilityCatName = tok.substring(9);
        final refCtx = context.getReferenceContext();
        final existing = refCtx.silentlyGetConstructedCDOMObject(
          'AbilityCategory',
          abilityCatName,
        );
        if (existing == null) {
          refCtx.constructCDOMObject('AbilityCategory', abilityCatName);
        }
        break;
      }
    }
    return super.process(sb, line, lineString, decider);
  }
}
