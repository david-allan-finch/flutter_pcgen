import '../base/cdom_object.dart';
import 'string_key.dart';
import 'object_key.dart';

// Controls how a data-source citation is formatted for display.
enum SourceFormat {
  short_,
  medium,
  long_,
  date,
  page,
  web;

  String? getField(CdomObject cdo) {
    switch (this) {
      case SourceFormat.short_:
        return cdo.get(StringKey.sourceShort);
      case SourceFormat.medium:
        return cdo.get(StringKey.sourceLong);
      case SourceFormat.long_:
        return cdo.get(StringKey.sourceLong);
      case SourceFormat.date:
        final d = cdo.get(ObjectKey.sourceDate);
        return d?.toString();
      case SourceFormat.page:
        return cdo.get(StringKey.sourcePage);
      case SourceFormat.web:
        return cdo.get(StringKey.sourceWeb);
    }
  }

  String getPublisher(CdomObject campaign) {
    switch (this) {
      case SourceFormat.long_:
        return (campaign.getSafe(StringKey.pubNameLong) as String?) ?? '';
      case SourceFormat.web:
        return (campaign.getSafe(StringKey.pubNameWeb) as String?) ?? '';
      default:
        return '';
    }
  }

  bool allowsPage() => this != SourceFormat.web;

  static String formatShort(CdomObject cdo, int aMaxLen) {
    String? theShortName = cdo.get(StringKey.sourceShort);
    if (theShortName == null) {
      final campaign = cdo.get(ObjectKey.sourceCampaign);
      if (campaign != null) {
        theShortName = (campaign as CdomObject).get(StringKey.sourceShort);
      }
    }
    if (theShortName != null) {
      final maxLen = aMaxLen < theShortName.length ? aMaxLen : theShortName.length;
      return theShortName.substring(0, maxLen);
    }
    return '';
  }

  static String getFormattedString(CdomObject cdo, SourceFormat format, bool includePage) {
    final ret = StringBuffer();
    if (cdo.isType('Custom')) {
      ret.write('Custom - ');
    }

    String? source = format.getField(cdo);
    String? publisher;
    final campaign = cdo.get(ObjectKey.sourceCampaign);
    if (campaign != null) {
      publisher = format.getPublisher(campaign as CdomObject);
      source ??= format.getField(campaign as CdomObject);
    }
    source ??= '';

    if (publisher != null && publisher.trim().isNotEmpty) {
      ret.write(publisher);
      ret.write(' - ');
    }
    ret.write(source);

    if (includePage && format.allowsPage()) {
      final pageNumber = cdo.get(StringKey.sourcePage);
      if (pageNumber != null) {
        if (ret.length != 0) ret.write(', ');
        ret.write(pageNumber);
      }
    }
    return ret.toString();
  }
}
