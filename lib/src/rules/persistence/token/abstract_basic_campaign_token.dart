// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.token.AbstractBasicCampaignToken

import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'package:flutter_pcgen/src/rules/persistence/token/abstract_token_with_separator.dart';
import 'package:flutter_pcgen/src/rules/persistence/token/parse_result.dart';

/// Abstract base for Campaign-scoped tokens that store [CampaignSourceEntry]
/// values in a [ListKey].
///
/// Delegates parse validation to [AbstractTokenWithSeparator] (uses '|' as the
/// separator), then resolves the raw value string to a [CampaignSourceEntry]
/// via the [LoadContext] and adds it to the list identified by [getListKey].
///
/// TODO: The following Java types have not yet been ported:
///   - Campaign (use dynamic for now)
///   - CampaignSourceEntry (use dynamic)
///   - ListKey<CampaignSourceEntry> (use dynamic)
///   - context.getCampaignSourceEntry(campaign, value)
///   - context.getObjectContext().addToList(campaign, listKey, cse)
///   - context.getObjectContext().getListChanges(campaign, listKey)
///
/// Mirrors Java: AbstractBasicCampaignToken extends AbstractTokenWithSeparator<Campaign>
abstract class AbstractBasicCampaignToken
    extends AbstractTokenWithSeparator<dynamic> {
  @override
  String separator() => '|';

  @override
  ParseResult parseTokenWithSeparator(
      LoadContext context, dynamic campaign, String value) {
    // TODO: implement once CampaignSourceEntry + Campaign context ops are ported.
    // Java logic:
    //   CampaignSourceEntry cse = context.getCampaignSourceEntry(campaign, value);
    //   if (cse == null) return ParseResult.internalError;
    //   context.getObjectContext().addToList(campaign, getListKey(), cse);
    //   return ParseResult.success;
    throw UnimplementedError(
        'AbstractBasicCampaignToken.parseTokenWithSeparator: '
        'requires CampaignSourceEntry + Campaign context ops');
  }

  /// The [ListKey] that identifies which list the parsed [CampaignSourceEntry]
  /// should be stored in.
  ///
  /// TODO: type to ListKey<CampaignSourceEntry> once ported.
  dynamic getListKey();

  /// Serialises the list of [CampaignSourceEntry] values back to LST strings.
  ///
  /// Returns null when the list is empty (no token to write).
  ///
  /// TODO: implement once CampaignSourceEntry + context list-changes are ported.
  List<String>? unparse(LoadContext context, dynamic campaign) {
    // Java logic:
    //   Changes<CampaignSourceEntry> cseChanges =
    //       context.getObjectContext().getListChanges(campaign, getListKey());
    //   Collection<CampaignSourceEntry> added = cseChanges.getAdded();
    //   if (added == null) return null;
    //   Set<String> set = new TreeSet<>();
    //   for (CampaignSourceEntry cse : added) set.add(cse.getLSTformat());
    //   return set.toArray(new String[0]);
    throw UnimplementedError(
        'AbstractBasicCampaignToken.unparse: '
        'requires CampaignSourceEntry + context list-changes');
  }

  @override
  Type getTokenClass() {
    // TODO: return Campaign once ported.
    return dynamic;
  }
}
