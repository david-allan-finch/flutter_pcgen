//
// CampaignURL.java
// Copyright 2008 (C) James Dempsey
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
// Translation of pcgen.cdom.content.CampaignURL
// A typed and labelled URL for a campaign.
enum UrlKind { website, survey, purchase }

class CampaignURL implements Comparable<CampaignURL> {
  final UrlKind urlKind;
  final String urlName;
  final Uri uri;
  final String urlDesc;

  CampaignURL(this.urlKind, this.urlName, this.uri, this.urlDesc);

  UrlKind getUrlKind() => urlKind;
  String getUrlName() => urlName;
  Uri getUri() => uri;
  String getUrlDesc() => urlDesc;

  @override
  int compareTo(CampaignURL that) {
    if (identical(this, that)) return 0;
    final kindCmp = urlKind.index - that.urlKind.index;
    if (kindCmp != 0) return kindCmp;
    final nameCmp = urlName.compareTo(that.urlName);
    if (nameCmp != 0) return nameCmp;
    final uriCmp = uri.toString().compareTo(that.uri.toString());
    if (uriCmp != 0) return uriCmp;
    return urlDesc.compareTo(that.urlDesc);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CampaignURL) return false;
    return other.urlKind == urlKind &&
        other.urlName == urlName &&
        other.uri == uri &&
        other.urlDesc == urlDesc;
  }

  @override
  int get hashCode => uri.hashCode;
}
