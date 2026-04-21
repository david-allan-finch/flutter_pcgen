//
// Copyright 2002 (C) Thomas Behr <ravenlock@gmx.de>
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
// Translation of pcgen.io.PCGParseException

/// Thrown when a PCG character file cannot be parsed.
class PCGParseException implements Exception {
  final String message;
  final int lineNumber;
  final Object? cause;

  PCGParseException(this.message, {this.lineNumber = -1, this.cause});

  @override
  String toString() =>
      'PCGParseException${lineNumber >= 0 ? ' (line $lineNumber)' : ''}: $message';
}
