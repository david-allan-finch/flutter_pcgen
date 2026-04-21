// Copyright 2014 James Dempsey
//
// Translation of pcgen.persistence.lst.InstallLstToken

import 'package:flutter_pcgen/src/persistence/lst/lst_token.dart';

/// Interface for tokens in install.lst files.
abstract interface class InstallLstToken implements LstToken {
  /// Parses [value] into [campaign] from the file at [sourceURI].
  bool parse(dynamic campaign, String value, Uri sourceURI);
}
