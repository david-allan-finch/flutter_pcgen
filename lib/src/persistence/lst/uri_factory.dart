// Copyright 2003 David Hibbs <sage_sam@users.sourceforge.net>
//
// Translation of pcgen.persistence.lst.URIFactory

import 'dart:io';

/// Constructs a URI from a root URI and an offset string, following PCGen's
/// resolution rules (absolute paths, relative paths, and special @-prefixes
/// for data/vendor/homebrew directories).
class UriFactory {
  static final Uri failedUri = Uri.file('/FAIL');

  final Uri rootUri;
  final String offset;

  UriFactory(this.rootUri, this.offset);

  Uri getRootUri() => rootUri;
  String getOffset() => offset;

  /// Resolves the URI from [rootUri] and [offset].
  Uri resolve() {
    try {
      if (offset.startsWith('@')) {
        // Special prefix resolution (data/, vendor/, homebrew/ etc.)
        // TODO: implement PCGenSettings path resolution
        return failedUri;
      }
      final offsetUri = Uri.parse(offset);
      if (offsetUri.isAbsolute) return offsetUri;
      return rootUri.resolve(offset);
    } catch (_) {
      return failedUri;
    }
  }

  @override
  String toString() => '$rootUri + $offset';
}
