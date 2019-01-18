import 'package:quiver/collection.dart';
import 'package:quiver/core.dart';

import './relay_store_types.dart';

enum RelayConcreteNode {
  condition,
  fragment,
  fragment_spread,
  inline_fragment,
  linked_field,
  linked_handle,
  literral,
  local_argument,
  match_field,
  operation,
  request,
  root_argument,
  scalar_field,
  scalar_handle,
  split_operation,
  varibale,
}

class RelayReader {
  RecordSource _recordSource;
  Map<String, Optional<Record>> _seenRecords;
  Variables _variables;
  bool _isMissingData;

  RelayReader(RecordSource recordSource, Variables variables) {
    this._recordSource = recordSource;
    this._variables = variables;
    this._isMissingData = false;
    this._seenRecords = {};
  }
}


