// Auto-updated on each commit — check this matches the running app.
const int kBuildNumber = 153;

const int kVersionMajor = 7;
const int kVersionMinor = 0;

/// 'alpha', 'beta', 'rc.1', or '' for production.
const String kVersionQualifier = 'alpha';

/// Full semver-style string: 7.0.147-alpha
String get kVersionString {
  final q = kVersionQualifier.isEmpty ? '' : '-$kVersionQualifier';
  return '$kVersionMajor.$kVersionMinor.$kBuildNumber$q';
}

/// Shorter form used in the title bar: v7.0.147-alpha
String get kVersionBadge => 'v$kVersionString';
