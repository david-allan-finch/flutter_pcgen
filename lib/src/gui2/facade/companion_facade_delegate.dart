//
// Copyright 2012 (C) Connor Petty <cpmeister@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.gui2.facade.CompanionFacadeDelegate

import 'package:flutter_pcgen/src/core/race.dart';
import 'package:flutter_pcgen/src/facade/core/companion_facade.dart';
import 'package:flutter_pcgen/src/facade/util/default_reference_facade.dart';
import 'package:flutter_pcgen/src/facade/util/reference_facade.dart';

/// A CompanionFacade implementation that delegates to another CompanionFacade.
/// All internal reference facades are themselves delegates to the underlying
/// CompanionFacade.
class CompanionFacadeDelegate implements CompanionFacade {
  CompanionFacade? _delegate;

  final _DelegateReferenceFacade<String> _nameDelegate =
      _DelegateReferenceFacade<String>();
  final _DelegateReferenceFacade<String> _fileDelegate =
      _DelegateReferenceFacade<String>(); // file path as String
  final _DelegateReferenceFacade<Race> _raceDelegate =
      _DelegateReferenceFacade<Race>();

  CompanionFacadeDelegate();

  void setCompanionFacade(CompanionFacade companionFacade) {
    _delegate = companionFacade;
    _nameDelegate.setDelegate(companionFacade.getNameRef());
    _fileDelegate.setDelegate(companionFacade.getFileRef());
    _raceDelegate.setDelegate(companionFacade.getRaceRef());
  }

  /// Returns the CompanionFacade backing this delegate.
  CompanionFacade? getDelegate() => _delegate;

  @override
  ReferenceFacade<String> getNameRef() => _nameDelegate;

  @override
  ReferenceFacade<String> getFileRef() => _fileDelegate;

  @override
  ReferenceFacade<Race> getRaceRef() => _raceDelegate;

  @override
  String? getCompanionType() => _delegate?.getCompanionType();
}

// ---------------------------------------------------------------------------

class _DelegateReferenceFacade<T> extends DefaultReferenceFacade<T> {
  ReferenceFacade<T>? _delegate;

  void setDelegate(ReferenceFacade<T>? newDelegate) {
    _delegate?.removeReferenceListener(_onRefChanged);
    _delegate = newDelegate;
    if (_delegate != null) {
      _delegate!.addReferenceListener(_onRefChanged);
      set(_delegate!.get());
    } else {
      set(null);
    }
  }

  void _onRefChanged(dynamic event) {
    set(event.newReference as T?);
  }
}
