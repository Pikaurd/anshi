import 'package:quiver/collection.dart';
import 'package:quiver/core.dart';

import '../util/dart_relay_node.dart';
import './relay_store_types.dart';
import './relay_record_state.dart';

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

Snapshot read(RecordSource recordSource, ReaderSelector<RelayObject> selector) {
  final dataID = selector.dataID;
  final node = selector.readerNode;
  final variables = selector.variables;
  final reader = RelayReader(recordSource, variables);
  return reader.read(node, dataID);
}

class RelayReader {
  RecordSource _recordSource;
  RecordMap _seenRecords;
  Variables _variables;
  bool _isMissingData;

  RelayReader(RecordSource recordSource, Variables variables) {
    this._recordSource = recordSource;
    this._variables = variables;
    this._isMissingData = false;
    this._seenRecords = RecordMap();
  }

  Snapshot read(RelayObject node, String dataID) {
    final data = this._traverse(node, dataID, null);
    Snapshot snapshot = _SnapShotImpl();
    snapshot.data = data;
    snapshot.dataID = dataID;
    snapshot.readerNode = node;
    snapshot.seenRecords = this._seenRecords;
    snapshot.variables = this._variables;
    _isMissingData = this._isMissingData;
    return snapshot;
  }

  Optional<Map<String, dynamic>> _traverse(RelayObject node, String dataID, [Map<String, dynamic> prevData]) {
    final record = this._recordSource.get(dataID);
    this._seenRecords[dataID] = record.isPresent ? record.value : null;
    if (record.isEmpty) {
      if (this._recordSource.getStatus(dataID) == RecordState.unknown) {
        this._isMissingData = true;
      }
      return record;
    }

    final data = prevData == null ? Map<String, dynamic>() : prevData;
    this._traverseSelections(node['selections'], record.value, data);
    return Optional.fromNullable(data);
  }

  void _traverseSelections(List<GeneratedNode> selections, Record record, Map<String, dynamic> data) {
    selections.forEach((selection) {
      // final String kind = selection['kind'];
      // if (kind == _scalarField) {
      //   this._readScalar(selection, record, data);
      // } else if (kind == _linkedField) {
      //   if (selection['plural']) {
      //     this._readPluralLink(selection, record, data);
      //   } else {
      //     this._readLink(selection, record, data);
      //   }
      // } else if (kind == _condition) {

      // } else if (kind == _inlineFragment) {

      // } else if (kind == '' /* fragment spread */) {
      // } else if (kind == _matchField) {
      // } else  {
      //   throw 'RelayReader(): Unexprected kind $kind':
      // }
    });
  }


}

class _SnapShotImpl extends Snapshot {}

const _operation = 'Operation';
const _linkedHandle = 'LinkedHandle';
const _scalarHandle = 'ScalarHandle';
const _condition = 'Condition';
const _rootArgument = 'RootArgument';
const _inlineFragment = 'InlineFragment';
const _linkedField = 'LinkedField';
const _matchField = 'MatchField';
const _literal = 'Literal';
const _localArgument = 'LocalArgument';
const _scalarField = 'ScalarField';
const _splitOperation = 'SplitOperation';
const _variable = 'Variable';
