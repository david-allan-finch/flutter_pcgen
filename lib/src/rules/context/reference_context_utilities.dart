//
// Copyright 2007-14 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.rules.context.ReferenceContextUtilities
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/base/class_identity.dart';
import 'package:flutter_pcgen/src/cdom/base/loadable.dart';
import 'package:flutter_pcgen/src/cdom/reference/reference_manufacturer.dart';
import 'package:flutter_pcgen/src/cdom/reference/unconstructed_validator.dart';
import 'package:flutter_pcgen/src/rules/context/load_validator.dart';
import 'runtime_reference_context.dart' show AbstractReferenceContext;

class ReferenceContextUtilities {
  ReferenceContextUtilities._(); // Do not instantiate utility class

  /// Check the associations now that all the data is loaded.
  ///
  /// [validator] is the helper object to track things such as FORWARDREF instances.
  static void validateAssociations(
    AbstractReferenceContext refContext,
    LoadValidator? validator,
  ) {
    for (final rm in refContext.getAllManufacturers()) {
      for (final singleRef in rm.getReferenced()) {
        // stub: CDOMSingleRef does not yet expose getChoice(); cast to dynamic
        final choice = (singleRef as dynamic).getChoice() as String?; // stub
        if (choice != null) {
          final cdo = singleRef.get() as CDOMObject;
          // stub: CDOMObjectKey.CHOOSE_INFO lookup requires CDOMObjectKey support
          final ci = cdo.get(null) as dynamic; // stub
          if (ci == null) {
            // stub: Logging.errorPrint equivalent
            print(
                'Found ${rm.getReferenceDescription()} ${cdo.getKeyName()}'
                ' that had association: $choice but was not an object with CHOOSE');
            rm.fireUnconstructedEvent(singleRef);
            continue;
          }
          if (choice.contains('%')) {
            // Patterns or %LIST are OK
            continue;
          }
          final cl = ci.getReferenceClass() as Type;
          // stub: Loadable.class.isAssignableFrom(cl) check omitted
          {
            final mfg = refContext.getManufacturerByFormatName(
              ci.getPersistentFormat() as String,
              cl,
            );
            if (mfg != null &&
                !mfg.containsObjectKeyed(choice) &&
                // stub: TokenLibrary.getPrimitive omitted
                !_report(validator, mfg.getReferenceIdentity(), choice)) {
              // stub: Logging.errorPrint equivalent
              print(
                  'Found ${rm.getReferenceDescription()} ${cdo.getKeyName()}'
                  ' that had association: $choice but no such'
                  ' ${mfg.getReferenceDescription()} was ever defined');
              rm.fireUnconstructedEvent(singleRef);
            }
          }
        }
      }
    }
  }

  static bool _report(
      UnconstructedValidator? validator, ClassIdentity<dynamic> cl, String key) {
    return validator != null && validator.allowUnconstructed(cl, key);
  }

  /// Resolve a token string of the form "ObjectType[=Category]" to a
  /// ReferenceManufacturer.
  static ReferenceManufacturer<dynamic>? getManufacturer(
    AbstractReferenceContext refContext,
    String firstToken,
  ) {
    final equalLoc = firstToken.indexOf('=');
    final String className;
    final String? categoryName;

    if (equalLoc != firstToken.lastIndexOf('=')) {
      // stub: Logging.log equivalent
      print('  Error encountered: Found second = in ObjectType=Category');
      print('  Format is: ObjectType[=Category]|Key[|Key] value was: $firstToken');
      print('  Valid ObjectTypes are: (StringPClassUtil.getValidStrings stub)');
      return null;
    } else if (firstToken == 'FEAT') {
      className = 'ABILITY';
      categoryName = 'FEAT';
    } else if (equalLoc == -1) {
      className = firstToken;
      categoryName = null;
    } else {
      className = firstToken.substring(0, equalLoc);
      categoryName = firstToken.substring(equalLoc + 1);
    }

    // stub: StringPClassUtil.getClassFor not yet available in Dart
    final Type? c = _getClassFor(className);
    if (c == null) {
      print('Unrecognized ObjectType: $className');
      return null;
    }

    // stub: Categorized.class.isAssignableFrom(c) check simplified
    final bool isCategorized = _isCategorized(c);

    if (isCategorized) {
      if (categoryName == null) {
        print('  Error encountered: Found Categorized Type without =Category');
        print('  Format is: ObjectType[=Category]|Key[|Key] value was: $firstToken');
        return null;
      }
      final rm = refContext.getManufacturerByFormatName(firstToken, c);
      if (rm == null) {
        print('  Error encountered: $className Category: $categoryName not found');
        return null;
      }
      return rm;
    } else {
      if (categoryName != null) {
        print('  Error encountered: Found Non-Categorized Type with =Category');
        print('  Format is: ObjectType[=Category]|Key[|Key] value was: $firstToken');
        return null;
      }
      return refContext.getManufacturer(c);
    }
  }

  // stub: delegates to StringPClassUtil which is not yet translated
  static Type? _getClassFor(String className) => null; // stub

  // stub: real check uses Categorized.class.isAssignableFrom
  static bool _isCategorized(Type c) => false; // stub
}
