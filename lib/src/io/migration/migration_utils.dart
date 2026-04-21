//
// Copyright 2013 (C) James Dempsey <jdempsey@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
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
