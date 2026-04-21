//
// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.util.AbstractRadioListMenu

import 'package:flutter/material.dart';

import 'package:flutter_pcgen/src/facade/util/list_facade.dart';
import 'package:flutter_pcgen/src/facade/util/event/list_event.dart';
import 'abstract_list_menu.dart';

/// A dynamic menu that displays each item as a radio-button entry.
/// Only one item can be selected at a time.
abstract class AbstractRadioListMenu<E> extends StatefulWidget {
  final String label;
  final ListFacade<E>? listModel;

  const AbstractRadioListMenu({
    super.key,
    required this.label,
    this.listModel,
  });
}

abstract class AbstractRadioListMenuState<E,
        W extends AbstractRadioListMenu<E>> extends State<W> {
  ListFacade<E>? _listModel;
  List<E> _items = [];
  E? _selectedItem;

  @override
  void initState() {
    super.initState();
    _setListModel(widget.listModel);
  }

  @override
  void didUpdateWidget(W oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.listModel != oldWidget.listModel) {
      _setListModel(widget.listModel);
    }
  }

  @override
  void dispose() {
    _listModel?.removeListListener(_listener);
    super.dispose();
  }

  late final _ListenerAdapter<E> _listener = _ListenerAdapter(this);

  void _setListModel(ListFacade<E>? model) {
    _listModel?.removeListListener(_listener);
    _listModel = model;
    if (model != null) {
      model.addListListener(_listener);
      _rebuildItems();
    } else {
      setState(() => _items = []);
    }
  }

  void _rebuildItems() {
    final model = _listModel;
    if (model == null) return;
    final List<E> newItems = [];
    for (int i = 0; i < model.getSize(); i++) {
      newItems.add(model.getElementAt(i));
    }
    setState(() => _items = newItems);
  }

  void setSelectedItem(E? item) {
    setState(() => _selectedItem = item);
  }

  void clearSelection() {
    setState(() => _selectedItem = null);
  }

  void onItemSelected(E item);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<E>(
      enabled: _items.isNotEmpty,
      tooltip: widget.label,
      onSelected: onItemSelected,
      itemBuilder: (_) => _items
          .asMap()
          .entries
          .map(
            (entry) => CheckedPopupMenuItem<E>(
              value: entry.value,
              checked: entry.value == _selectedItem,
              child: Text(entry.value.toString()),
            ),
          )
          .toList(),
      child: Text(widget.label),
    );
  }
}

class _ListenerAdapter<E> {
  final AbstractRadioListMenuState<E, AbstractRadioListMenu<E>> _state;

  _ListenerAdapter(this._state);

  void elementAdded(ListEvent<E> e) => _state._rebuildItems();
  void elementRemoved(ListEvent<E> e) => _state._rebuildItems();
  void elementsChanged(ListEvent<E> e) => _state._rebuildItems();
  void elementModified(ListEvent<E> e) {}
}
