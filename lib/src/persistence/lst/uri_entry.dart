// Copyright 2003 David Hibbs <sage_sam@users.sourceforge.net>
//
// Translation of pcgen.persistence.lst.URIEntry

import 'package:flutter_pcgen/src/persistence/lst/uri_factory.dart';

/// Associates a URI (or deferred URIFactory) with a campaign name.
class UriEntry {
  final String campaignName;
  final UriFactory? _uriFactory;
  Uri? _uri;

  UriEntry.direct(this.campaignName, Uri uri)
      : _uriFactory = null,
        _uri = uri;

  UriEntry._factory(this.campaignName, this._uriFactory);

  /// Lazily resolves the URI from the factory on first access.
  Uri get uri {
    if (_uri != null) return _uri!;
    _uri = _uriFactory!.resolve();
    return _uri!;
  }

  String getCampaignName() => campaignName;

  /// Returns the URI (may trigger lazy resolution).
  Uri getUri() => uri;
}
