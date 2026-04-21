// *
// Copyright James Dempsey, 2011
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
// Translation of pcgen.gui2.facade.DescriptionFacadeImpl

import 'package:flutter/foundation.dart';
import '../../facade/core/description_facade.dart';

/// Implementation of DescriptionFacade — manages character biography/description fields.
class DescriptionFacadeImpl extends ChangeNotifier implements DescriptionFacade {
  final Map<String, dynamic> _data;

  DescriptionFacadeImpl(this._data);

  @override
  String getBiography() => _str('biography');

  @override
  void setBiography(String bio) => _set('biography', bio);

  @override
  String getDescription() => _str('description');

  @override
  void setDescription(String desc) => _set('description', desc);

  @override
  String getPortraitPath() => _str('portraitPath');

  @override
  void setPortraitPath(String path) => _set('portraitPath', path);

  @override
  String getThumbnailPath() => _str('thumbnailPath');

  @override
  void setThumbnailPath(String path) => _set('thumbnailPath', path);

  @override
  List<dynamic> getCampaignHistory() {
    final h = _data['campaignHistory'];
    return h is List ? h : [];
  }

  @override
  void addCampaignHistory(dynamic entry) {
    final h = _data.putIfAbsent('campaignHistory', () => <dynamic>[]) as List;
    h.add(entry);
    notifyListeners();
  }

  @override
  void removeCampaignHistory(dynamic entry) {
    final h = _data['campaignHistory'];
    if (h is List) {
      h.remove(entry);
      notifyListeners();
    }
  }

  String _str(String key) => (_data[key] as String?) ?? '';

  void _set(String key, String value) {
    if (_data[key] == value) return;
    _data[key] = value;
    notifyListeners();
  }
}
