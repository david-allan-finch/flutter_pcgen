// Translation of pcgen.persistence.lst.TabLoader

import '../../rules/context/load_context.dart';
import 'simple_loader.dart';

/// Loads TabInfo objects from tab .lst files in the game mode directory.
///
/// TabInfo defines the tabs shown in the PCGen UI (e.g. Summary, Class, Skills).
/// Each line is a tab definition with TOKEN:value pairs.
class TabLoader extends SimpleLoader<dynamic> {
  TabLoader() : super(dynamic);

  @override
  dynamic getLoadable(dynamic context, String firstToken, Uri sourceUri) {
    if (firstToken.isEmpty) return null;
    // TODO: construct TabInfo via context and register it
    // Java: context.getReferenceContext().constructNowIfNecessary(TabInfo.class, name)
    return null;
  }
}
