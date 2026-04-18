// Utility class assisting with LST file parsing.
class LstUtils {
  LstUtils._(); // utility class

  static const String pipe = '|';
  static const String comma = ',';

  /// Split [token] at the first ':' into [tag, value].
  /// Returns [token, ''] if no ':' found.
  static (String tag, String value) splitToken(String token) {
    final colonIdx = token.indexOf(':');
    if (colonIdx == -1) return (token, '');
    return (token.substring(0, colonIdx), token.substring(colonIdx + 1));
  }

  /// Returns true if [tokenName] starts with 'PRE' or '!PRE'.
  static bool isPrereqToken(String tokenName) =>
      tokenName.startsWith('PRE') || tokenName.startsWith('!PRE');

  /// Returns true if [value] starts with 'BONUS'.
  static bool isBonusToken(String value) => value.startsWith('BONUS');
}
