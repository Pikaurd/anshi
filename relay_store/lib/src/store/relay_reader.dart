import 'package:quiver/collection.dart';
import 'package:quiver/core.dart';

import '../util/dart_relay_node.dart';
import '../util/invariant.dart';
import './relay_store_types.dart';
import './relay_record.dart' as RelayRecord;
import './relay_record_state.dart';
import './relay_store_utils.dart';

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

  dynamic _getVariableValue(String name) {
    invariant(this._variables.containsKey(name), 'RelayReader(): Undefined variable `$name`');
    return this._variables[name];
  }

  void _traverseSelections(List<GeneratedNode> selections, Record record, Map<String, dynamic> data) {
    selections.forEach((selection) {
      final String kind = selection['kind'];
      if (kind == _scalarField) {
        this._readScalar(selection, record, data);
      } else if (kind == _linkedField) {
        if (selection['plural']) {
          this._readPluralLink(selection, record, data);
        } else {
          this._readLink(selection, record, data);
        }
      } else if (kind == _condition) {
        final conditionValue = this._getVariableValue(selection['condition']);
        if (conditionValue == selection['passingValue']) {
          this._traverseSelections(selection['selections'], record, data);
        }
      } else if (kind == _inlineFragment) {
        final typeName = RelayRecord.getType(record);
        if (typeName != null && typeName == selection['type']) {
          this._traverseSelections(selections, record, data);
        }
      } else if (kind == '' /* fragment spread */) {
        throw 'RelayReader: fragment spread not implemented';
      } else if (kind == _matchField) {
        throw 'RelayReader: matchField not implemented';
      } else  {
        throw 'RelayReader(): Unexprected kind $kind';
      }
    });
  }

  void _readScalar(GeneratedNode field, Record record, Map<String, dynamic> data) {
    final applicationName = field['name'];
    final storageKey = getStorageKey(field, this._variables);
    final linkedID = RelayRecord.getLinkedRecordID(record, storageKey);
    if (linkedID.isEmpty) {
      data[applicationName] = linkedID;
      if (!record.containsKey(storageKey)) {
        this._isMissingData = true;
      }
      return;
    }

    // final prevData = data[applicationName]; TODO: invarient

    final linkedRecord = this._recordSource.get(linkedID.value);
    this._seenRecords[linkedID.value] = linkedRecord.value;
    if (linkedRecord.isEmpty) {
      if (this._recordSource.getStatus(linkedID.value) == RecordState.unknown) {
        this._isMissingData = true;
      }
      data[applicationName] = linkedRecord.value;
      return;
    }

    throw 'not implemented';
  }

  void _readLink(GeneratedNode field, Record record, Map<String, dynamic> data) {
    final applicationName = field['name'];
    final storageKey = getStorageKey(field, this._variables);
    final linkedID = RelayRecord.getLinkedRecordID(record, storageKey);
    if (linkedID.isEmpty) {
      data[applicationName] = Optional.absent();
      if (!record.containsKey(storageKey)) {
        this._isMissingData = true;
      }
      return;
    }

    final prevData = data[applicationName];
    invariant(prevData != null, 'RelayReader(): Expected data for field `$applicationName` on record `${RelayRecord.getDataID(record)}` to be an object');
    data[applicationName] = this._traverse(field, linkedID.value, prevData);
  }

  void _readPluralLink(GeneratedNode field, Record record, Map<String, dynamic> data) {
    final applicationName = field['name'];
    final storageKey = getStorageKey(field, this._variables);
    final linkedIDs = RelayRecord.getLinkedRecordIDs(record, storageKey);

    if (linkedIDs.isEmpty) {
      data[applicationName] = Optional.absent();
      if (!record.containsKey(storageKey)) {
        this._isMissingData = true;
      }
      return ;
    }

    final prevData = data[applicationName];
    invariant(prevData == null, 'RelayReader(): Expected data for field `$applicationName` on record `${RelayRecord.getDataID(record)}`');
    final linkedArray = prevData == null ? [] : prevData;
    linkedIDs.value.asMap().forEach((nextIndex, linkedID) {
      if (linkedID == null) {
        // TODO: undefined not handle
        linkedArray[nextIndex] = linkedID;
        return;
      }
      final prevItem = linkedArray[nextIndex];
      linkedArray[nextIndex] = this._traverse(field, linkedID, prevItem);
    });
    data[applicationName] = linkedArray;
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
