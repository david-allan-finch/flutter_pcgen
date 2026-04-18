// Copyright 2008 Tom Parker <thpr@users.sourceforge.net>
//
// Translation of pcgen.rules.persistence.util.Revision

/// Represents a PCGen version number (major.minor.patch), supporting comparison.
class Revision implements Comparable<Revision> {
  final int major;
  final int minor;
  final int patch;

  const Revision(this.major, this.minor, this.patch);

  @override
  int compareTo(Revision other) {
    if (major != other.major) return major > other.major ? -1 : 1;
    if (minor != other.minor) return minor > other.minor ? -1 : 1;
    if (patch != other.patch) return patch > other.patch ? -1 : 1;
    return 0;
  }

  @override
  bool operator ==(Object other) =>
      other is Revision && compareTo(other) == 0;

  @override
  int get hashCode => major * minor + patch;

  @override
  String toString() => '$major.$minor-$patch';
}
