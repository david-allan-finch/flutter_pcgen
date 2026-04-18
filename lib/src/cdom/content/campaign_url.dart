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
