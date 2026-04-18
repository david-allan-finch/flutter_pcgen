import '../cdom/enumeration/object_key.dart';
import 'pcobject.dart';

// Definition and game rules for an Ability (feat, special ability, etc).
final class Ability extends PObject {
  String getCategory() {
    final catRef = getObject(ObjectKey.getConstant<dynamic>('ABILITY_CAT'));
    return (catRef as dynamic)?.getKeyName() ?? '';
  }

  @override
  Ability clone() {
    final copy = Ability();
    // Shallow clone - copy key properties
    copy.setDisplayName(getDisplayName());
    copy.setKeyName(getKeyName());
    return copy;
  }

  String getPCCText() {
    final sb = StringBuffer();
    sb.write(getKeyName());
    // Additional fields would be added here in full implementation
    return sb.toString();
  }
}
