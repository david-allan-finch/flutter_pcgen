//
// Copyright (c) 2009 Tom Parker <thpr@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.gui2.converter.loader.SelfCopyLoader

import '../conversion_decider.dart';
import '../loader.dart';

/// A [Loader] that copies lines verbatim and returns the campaign's own PCC
/// file as the single entry in [getFiles].  Used to ensure the campaign
/// descriptor file itself is written to the output directory.
class SelfCopyLoader implements Loader {
  @override
  List<dynamic>? process(
    StringBuffer sb,
    int line,
    String lineString,
    ConversionDecider decider,
  ) {
    sb.write(lineString);
    return null;
  }

  @override
  List<dynamic> getFiles(dynamic campaign) {
    // Returns a single CampaignSourceEntry pointing at the campaign's own URI.
    return [_SelfCampaignSourceEntry(campaign, campaign.getSourceUri())];
  }
}

/// Lightweight stand-in for Java's CampaignSourceEntry when pointing a
/// campaign at its own source file.
class _SelfCampaignSourceEntry {
  final dynamic campaign;
  final Uri uri;

  _SelfCampaignSourceEntry(this.campaign, this.uri);

  Uri getUri() => uri;
  dynamic getCampaign() => campaign;
}
