// Translation of pcgen.core.Deity

import '../cdom/enumeration/list_key.dart';
import '../cdom/enumeration/object_key.dart';
import 'domain.dart';
import 'pcobject.dart';

/// Represents a deity that a character can worship.
///
/// The deity's domains are stored in the DOMAINLIST list key.
/// Other properties (alignment, favoured weapons, worshippers) are held
/// via the standard CDOMObject key/value store inherited from PObject.
final class Deity extends PObject {
  static final ListKey<dynamic> domainListKey =
      ListKey.getConstant<dynamic>('DOMAIN_LIST');

  /// Returns the list of domains offered by this deity.
  List<Domain> getDomainList() =>
      getSafeListFor<Domain>(domainListKey);

  /// Returns the deity's favoured weapon key, if set.
  String? getFavWeaponKeyName() {
    final ref = getSafe(ObjectKey.getConstant<dynamic>('FAVORED_WEAPON'));
    return (ref as dynamic)?.get()?.getKeyName();
  }

  /// Returns a list of alignment strings this deity allows worshippers of.
  List<String> getAllowedAlignments() =>
      getSafeListFor<String>(ListKey.getConstant<String>('ALIGN'));

  @override
  String toString() => getDisplayName();
}
