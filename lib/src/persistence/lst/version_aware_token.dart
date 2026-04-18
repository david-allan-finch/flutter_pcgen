// Copyright 2013 James Dempsey <jdempsey@users.sourceforge.net>
//
// Translation of pcgen.persistence.lst.VersionAwareToken

/// Abstract base for LST tokens that need to validate a PCGen version number.
abstract class VersionAwareToken {
  String getTokenName();

  /// Returns true if [version] is a valid PCGen version string (e.g. "6.0.2").
  /// Logs an error and returns false if the version has fewer than 3 numeric parts.
  bool validateVersionNumber(String version) {
    final tokens = version.split(RegExp(r'[ .\-]'));
    if (tokens.length < 3) {
      // TODO: log LST_ERROR
      return false;
    }
    for (int i = 0; i < 3; i++) {
      final part = tokens[i];
      if (int.tryParse(part) == null) {
        if (i == 2 && part.startsWith('RC')) {
          // Release candidate suffix — ignore
          continue;
        }
        // TODO: log LST_ERROR
        return false;
      }
    }
    return true;
  }
}
