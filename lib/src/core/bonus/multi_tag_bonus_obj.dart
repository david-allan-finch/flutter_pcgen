import 'bonus_obj.dart';

// Abstract BonusObj subclass that maps token strings to integer tag indices.
abstract class MultiTagBonusObj extends BonusObj {
  @override
  bool parseToken(dynamic context, String token) {
    for (int i = 0; i < getBonusTagLength(); i++) {
      if (getBonusTag(i) == token) {
        addBonusInfo(i);
        return true;
      }
    }
    if (token.startsWith('TYPE=')) {
      addBonusInfo(token.replaceFirst('=', '.'));
    } else {
      addBonusInfo(token);
    }
    return true;
  }

  @override
  String unparseToken(Object obj) {
    if (obj is int) return getBonusTag(obj);
    return obj as String;
  }

  String getBonusTag(int tagNumber);
  int getBonusTagLength();
}
