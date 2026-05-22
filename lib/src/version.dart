// Auto-updated on each commit — check this matches the running app.
const int kBuildNumber = 146;

const int kVersionMajor = 7;
const int kVersionMinor = 0;

/// Full semver-style string: 7.0.146
String get kVersionString => '$kVersionMajor.$kVersionMinor.$kBuildNumber';

/// Shorter form used in the title bar: v7.0.146
String get kVersionBadge => 'v$kVersionString';
