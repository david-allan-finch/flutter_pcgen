//
// Copyright 2008 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.util.AbstractListMenu

import 'package:flutter/material.dart';

import 'package:flutter_pcgen/src/facade/util/list_facade.dart';
import 'package:flutter_pcgen/src/facade/util/event/list_event.dart';
import 'package:flutter_pcgen/src/facade/util/event/list_listener.dart';

/// A [PopupMenuButton]-style menu that is dynamically populated from a
/// [ListFacade]. Subclasses implement [createMenuItem] to produce the
/// appropriate menu entry for each element.
abstract class AbstractListMenu<E> extends StatefulWidget
    implements ListListener<E> {
  final String label;
  final ListFacade<E>? listModel;

  const AbstractListMenu({
    super.key,
    required this.label,
    this.listModel,
  });
}

abstract class AbstractListMenuState<E, W extends AbstractListMenu<E>>
    extends State<W> {
  ListFacade<E>? _listModel;
  List<E> _items = [];

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
    _listModel?.removeListListener(widget);
    super.dispose();
  }

  void _setListModel(ListFacade<E>? model) {
    _listModel?.removeListListener(widget);
    _listModel = model;
    if (model != null) {
      model.addListListener(widget);
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

  @override
  void elementAdded(ListEvent<E> e) => _rebuildItems();

  @override
  void elementRemoved(ListEvent<E> e) => _rebuildItems();

  @override
  void elementsChanged(ListEvent<E> e) => _rebuildItems();

  @override
  void elementModified(ListEvent<E> e) {}

  /// Subclasses create a [PopupMenuEntry] for [item] at [index].
  PopupMenuEntry<E> createMenuItem(E item, int index);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<E>(
      enabled: _items.isNotEmpty,
      tooltip: widget.label,
      itemBuilder: (_) => _items
          .asMap()
          .entries
          .map((e) => createMenuItem(e.value, e.key))
          .toList(),
      child: Text(widget.label),
    );
  }
}
