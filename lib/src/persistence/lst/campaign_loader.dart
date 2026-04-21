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
// Translation of pcgen.persistence.lst.CampaignLoader

import 'package:flutter_pcgen/src/core/campaign.dart';
import 'package:flutter_pcgen/src/core/globals.dart';
import 'package:flutter_pcgen/src/persistence/persistence_layer_exception.dart';

/// Loads a campaign (.pcc) file into the global campaign registry.
///
/// A .pcc file contains metadata and file lists (ABILITY, CLASS, RACE, etc.)
/// for a source book or homebrew supplement.
class CampaignLoader {
  /// Loads a single campaign PCC file from [uri] into Globals.
  Future<void> loadCampaignLstFile(Uri uri) async {
    // TODO: read the PCC file, parse each token line, populate campaign object
    final campaign = Campaign();
    campaign.setSourceUri(uri);

    // Derive a key from the URI (use last path segment without extension)
    final path = uri.path;
    final fileName = path.split('/').last;
    final keyName = fileName.endsWith('.pcc')
        ? fileName.substring(0, fileName.length - 4)
        : fileName;
    campaign.setName(keyName);

    Globals.addCampaign(campaign);
  }

  /// Processes INFOTEXT and SUB-CAMPAIGN tags to load any campaigns
  /// that [campaign] depends on.
  void initRecursivePccFiles(Campaign campaign) {
    // TODO: load dependent campaigns listed under the campaign's
    // INFOTEXT/SUBFILELIST/ALLOWDUPES tokens
  }
}
