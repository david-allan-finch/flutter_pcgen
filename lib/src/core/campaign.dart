//
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
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
// Translation of pcgen.core.Campaign
import 'package:flutter_pcgen/src/cdom/enumeration/integer_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'pcobject.dart';

// Represents a campaign/source book that can be loaded.
class Campaign extends PObject {
  Uri? _sourceUri;
  bool _loaded = false;
  bool _published = false;

  Uri? getSourceUri() => _sourceUri;
  void setSourceUri(Uri uri) { _sourceUri = uri; }

  bool isLoaded() => _loaded;
  void setLoaded(bool loaded) { _loaded = loaded; }

  bool isPublished() => _published;
  void setPublished(bool published) { _published = published; }

  String getDestination() => getSafeString(StringKey.destination);

  int getCampaignRank() => getSafeInt(IntegerKey.campaignRank);

  List<String> getSources() =>
      getSafeListFor<String>(ListKey.getConstant<String>('CAMPAIGN_SOURCE'));

  @override
  String toString() => getDisplayName();
}
