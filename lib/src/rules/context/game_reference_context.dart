//
// Copyright 2007 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.rules.context.GameReferenceContext
import '../../cdom/base/cdom_object.dart';
import '../../cdom/base/class_identity.dart';
import '../../cdom/base/loadable.dart';
import '../../cdom/reference/manufacturable_factory.dart';
import '../../cdom/reference/reference_manufacturer.dart';
import '../../cdom/reference/transparent_factory.dart';
import '../../cdom/reference/unconstructed_validator.dart';
import 'runtime_reference_context.dart'
    show AbstractReferenceContext, BasicClassIdentity, SimpleReferenceManufacturer;

/// A ReferenceContext capable of delegating transparent references to
/// references built later in the load process. Transparent references
/// allow resolution against a target that does not yet exist at creation time.
class GameReferenceContext extends AbstractReferenceContext {
  final Map<String, ReferenceManufacturer<dynamic>> _mapByPers = {};

  GameReferenceContext._();

  @override
  ReferenceManufacturer<T> getManufacturer<T extends Loadable>(Type cl) {
    // stub: Categorized check omitted (type system differs in Dart)
    final identity = BasicClassIdentity.getIdentity<T>(cl);
    return getManufacturerId<T>(identity);
  }

  @override
  ReferenceManufacturer<T> constructReferenceManufacturer<T extends Loadable>(
      ClassIdentity<T> identity) {
    return SimpleReferenceManufacturer<T>(
      TransparentFactory<T>(identity.getPersistentFormat(), identity.getReferenceClass()),
    );
  }

  @override
  List<ReferenceManufacturer<dynamic>> getAllManufacturers() =>
      List.of(_mapByPers.values);

  @override
  bool validate(UnconstructedValidator validator) => true;

  @override
  T? performCopy<T extends CDOMObject>(T obj, String copyName) {
    throw UnsupportedError('GameReferenceContext cannot copy objects');
  }

  @override
  T performMod<T extends CDOMObject>(T obj) {
    throw UnsupportedError('GameReferenceContext cannot mod objects');
  }

  @override
  bool hasManufacturer<T extends Loadable>(ClassIdentity<T> cl) => false;

  @override
  ReferenceManufacturer<T> getManufacturerFac<T extends Loadable>(
      ManufacturableFactory<T> factory) {
    throw UnsupportedError(
        'GameReferenceContext cannot provide a factory based manufacturer');
  }

  /// Return a new GameReferenceContext initialised as per AbstractReferenceContext.
  static GameReferenceContext createGameReferenceContext() {
    final context = GameReferenceContext._();
    context.initialize();
    return context;
  }

  @override
  ReferenceManufacturer<T> getManufacturerId<T extends Loadable>(
      ClassIdentity<T> identity) {
    final persistent = identity.getPersistentFormat();
    return getManufacturerByFormatName<T>(persistent, identity.getReferenceClass())!;
  }

  @override
  ReferenceManufacturer<T>? getManufacturerByFormatName<T extends Loadable>(
      String formatName, Type refClass) {
    var mfg = _mapByPers[formatName] as ReferenceManufacturer<T>?;
    if (mfg == null) {
      mfg = SimpleReferenceManufacturer<T>(
          TransparentFactory<T>(formatName, refClass));
      _mapByPers[formatName] = mfg;
    }
    return mfg;
  }
}
