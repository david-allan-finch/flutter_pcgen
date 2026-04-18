// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/fact/ChronicleEntryFacet.java

import '../../../enumeration/char_id.dart';
import '../base/abstract_list_facet.dart';

/// ChronicleEntryFacet is a Facet that tracks the chronicle entries that have
/// been entered for a Player Character.
class ChronicleEntryFacet extends AbstractListFacet<CharID, dynamic> {
  @override
  List<dynamic> getCopyForNewOwner(List<dynamic> componentSet) {
    List<dynamic> newCopies = [];
    for (dynamic entry in componentSet) {
      try {
        newCopies.add(entry.clone());
      } catch (e) {
        // Logging.errorPrint equivalent
        print('ChronicleEntryFacet.getCopyForNewOwner failed for $entry: $e');
      }
    }
    return newCopies;
  }

  /// Overrides the default behavior of AbstractListFacet, since we need to
  /// ensure we are storing all chronicle entries (otherwise duplicate blanks
  /// are skipped).
  @override
  List<dynamic> getComponentSet() {
    return [];
  }
}
