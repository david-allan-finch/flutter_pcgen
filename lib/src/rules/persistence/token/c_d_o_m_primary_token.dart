// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.token.CDOMPrimaryToken

import 'c_d_o_m_token.dart';
import 'c_d_o_m_write_token.dart';

/// A top-level LST token: can both parse and unparse an object.
abstract interface class CDOMPrimaryToken<T>
    implements CDOMToken<T>, CDOMWriteToken<T> {}
