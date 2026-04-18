// Utility methods for extracting spell-related info from equipment modifier strings.
final class EqModSpellInfo {
  static const String sCharges = 'CHARGES';

  EqModSpellInfo._();

  static String getSpellInfoString(String listEntry, String desiredInfo) {
    final offs = listEntry.indexOf('$desiredInfo[');
    final offs2 = listEntry.indexOf(']', offs + 1);
    if (offs >= 0 && offs2 > offs) {
      return listEntry.substring(offs + desiredInfo.length + 1, offs2);
    }
    return '';
  }

  static int getSpellInfo(String listEntry, String desiredInfo) {
    final info = getSpellInfoString(listEntry, desiredInfo);
    if (info.isNotEmpty) {
      try {
        return int.parse(info);
      } catch (_) {}
    }
    return 0;
  }

  static String setSpellInfo(String listEntry, String desiredInfo, String newValue) {
    final offs = listEntry.indexOf('$desiredInfo[');
    if (offs < 0) {
      return '$listEntry|$desiredInfo[$newValue]';
    }
    final offs2 = listEntry.indexOf(']', offs + 1);
    return listEntry.substring(0, offs + desiredInfo.length + 1) +
        newValue +
        listEntry.substring(offs2);
  }
}
