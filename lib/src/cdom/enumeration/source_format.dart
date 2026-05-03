//
// Copyright 2009 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.cdom.enumeration.SourceFormat
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';

// Controls how a data-source citation is formatted for display.
enum SourceFormat {
  short_,
  medium,
  long_,
  date,
  page,
  web;

  String? getField(CDOMObject cdo) {
    switch (this) {
      case SourceFormat.short_:
        return cdo.getString(StringKey.sourceShort);
      case SourceFormat.medium:
        return cdo.getString(StringKey.sourceLong);
      case SourceFormat.long_:
        return cdo.getString(StringKey.sourceLong);
      case SourceFormat.date:
        final d = cdo.getObject(CDOMObjectKey.sourceDate);
        return d?.toString();
      case SourceFormat.page:
        return cdo.getString(StringKey.sourcePage);
      case SourceFormat.web:
        return cdo.getString(StringKey.sourceWeb);
    }
  }

  String getPublisher(CDOMObject campaign) {
    switch (this) {
      case SourceFormat.long_:
        return (campaign.getSafeString(StringKey.pubNameLong) as String?) ?? '';
      case SourceFormat.web:
        return (campaign.getSafeString(StringKey.pubNameWeb) as String?) ?? '';
      default:
        return '';
    }
  }

  bool allowsPage() => this != SourceFormat.web;

  static String formatShort(CDOMObject cdo, int aMaxLen) {
    String? theShortName = cdo.getString(StringKey.sourceShort);
    if (theShortName == null) {
      final campaign = cdo.getObject(CDOMObjectKey.sourceCampaign);
      if (campaign != null) {
        theShortName = (campaign as CDOMObject).getString(StringKey.sourceShort);
      }
    }
    if (theShortName != null) {
      final maxLen = aMaxLen < theShortName.length ? aMaxLen : theShortName.length;
      return theShortName.substring(0, maxLen);
    }
    return '';
  }

  static String getFormattedString(CDOMObject cdo, SourceFormat format, bool includePage) {
    final ret = StringBuffer();
    if (cdo.isType('Custom')) {
      ret.write('Custom - ');
    }

    String? source = format.getField(cdo);
    String? publisher;
    final campaign = cdo.getObject(CDOMObjectKey.sourceCampaign);
    if (campaign != null) {
      publisher = format.getPublisher(campaign as CDOMObject);
      source ??= format.getField(campaign as CDOMObject);
    }
    source ??= '';

    if (publisher != null && publisher.trim().isNotEmpty) {
      ret.write(publisher);
      ret.write(' - ');
    }
    ret.write(source);

    if (includePage && format.allowsPage()) {
      final pageNumber = cdo.getString(StringKey.sourcePage);
      if (pageNumber != null) {
        if (ret.length != 0) ret.write(', ');
        ret.write(pageNumber);
      }
    }
    return ret.toString();
  }
}
