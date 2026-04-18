// Translation of pcgen.io.migration.MigrationUtils

/// Utility methods for migrating PCG character files between versions.
class MigrationUtils {
  MigrationUtils._();

  /// Returns the migration version for the given string.
  static List<int> parseVersion(String versionStr) {
    final parts = versionStr.split('.');
    return parts.map((p) => int.tryParse(p) ?? 0).toList();
  }

  static bool isVersionLessThan(List<int> version, List<int> compareTo) {
    for (int i = 0; i < compareTo.length; i++) {
      final v = i < version.length ? version[i] : 0;
      if (v < compareTo[i]) return true;
      if (v > compareTo[i]) return false;
    }
    return false;
  }
}
