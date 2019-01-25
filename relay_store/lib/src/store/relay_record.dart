import 'package:quiver/core.dart';
import 'package:built_collection/built_collection.dart';

import './relay_store_types.dart';
import './relay_store_utils.dart';
import '../util/invariant.dart';

const __DEV__ = !bool.fromEnvironment("dart.vm.product");

Record clone(Record record) {
  final newRecord = Record();
  newRecord.delegate.addEntries(record.delegate.entries);
  return newRecord;
}

void copyFields(Record source, Record sink) {
  for (final key in source.keys) {
    if (key != RelayUtilKeys.idKey && key != RelayUtilKeys.typenameKey) {
      sink[key] = source[key];
    }
  }
}

Optional<String> getLinkedRecordID(Record record, String storageKey) {
  final link = record[storageKey];
  if (link == null) return Optional.absent();

  invariant(
    link is Map && link.containsKey(RelayUtilKeys.refKey) && link[RelayUtilKeys.refKey] is String, 
    'getLinkedRecordID expect `${record[RelayUtilKeys.idKey]}.${storageKey}` to be a linked ID'); 

  return Optional.fromNullable(link[RelayUtilKeys.refKey]);
}

Optional<List<String>> getLinkedRecordIDs(Record record, String storageKey) {
  final links = record[storageKey];
  if (links == null) return Optional.absent();

  invariant(
    links is Map && links.containsKey(RelayUtilKeys.refsKey) && links[RelayUtilKeys.refsKey] is List, 
    'getLinkedRecordIDs expect `${record[RelayUtilKeys.idKey]}.${storageKey}`' + 
    ' to contain an array of linked IDs, got `${links}`'); 

  return Optional.fromNullable(links[RelayUtilKeys.refsKey]);
}

void setLinkedRecordID(Record record, String storageKey, String linkedID) {
  final link = Record({RelayUtilKeys.refKey: linkedID});
  record[storageKey] = link;
}

void setLinkedRecordIDs(Record record, String storageKey, List<String> linkedIDs) {
  final links = Record({RelayUtilKeys.refsKey: linkedIDs});
  record[storageKey] = links;
}

dynamic getValue(Record record, String storageKey) {
  final value = record[storageKey];
  if (value != null && value is Map) {
    invariant(
      !value.containsKey(RelayUtilKeys.refKey) && !value.containsKey(RelayUtilKeys.refsKey), 
      'getValue(): Expected a scalar (non-link) value for `${record[RelayUtilKeys.idKey]}.$storageKey` ' +
      'but found ${value.containsKey(RelayUtilKeys.refKey) ? "a linked record" : "plural linked records"}'
    );
  }
  return value;
}

Record create(String dataID, String typeName) {
  return Record({RelayUtilKeys.idKey: dataID, RelayUtilKeys.typenameKey: typeName});
}

void freeze(Record record) {
  throw 'freeze() not implemented';
}

Record update(Record prevRecord, Record nextRecord) {
  if (__DEV__) {
    final prevID = getDataID(prevRecord);
    final nextID = getDataID(nextRecord);
    warning(
      prevID == nextID, 
      'RelayRecord: Invalid record update, expected both versions of ' + 
      'the record to have the same id, got `$prevID` and `$nextID`.');

    final prevType = getType(prevRecord);
    final nextType = getType(nextRecord);
    warning(
      prevType == nextType, 
      'RelayRecord: Invalid record update, expected both versions of ' + 
      'record `$prevID` to have the same `${RelayUtilKeys.typenameKey}` ' + 
      'but got conflicting types `$prevType` and `$nextType`. ' + 
      'The GraphQL server likely violated the globally unique ' + 
      'id requirement by returning the same id for different objects.');
  }

  Record updated = null;
  final keys = nextRecord.keys;
  for (final key in keys) {
    if (updated != null || prevRecord[key] != nextRecord[key]) {
      updated = updated != null ? updated : Record(prevRecord.delegate);
      if (nextRecord[key] != RelayUtilKeys.unpublishFieldSentinel) {
        updated[key] = nextRecord[key];
      } else {
        updated.remove(key);
      }
    }
  }
  return updated != null ? updated : prevRecord;
}

Record merge(Record r1, Record r2) {
  return Record({}..addAll(r1.delegate)..addAll(r2.delegate));
}

void setValue(Record record, String storageKey, dynamic value) {
  record[storageKey] = value;
}

String getDataID(Record record) {
  return record[RelayUtilKeys.idKey];
}

String getType(Record record) {
  return record[RelayUtilKeys.typenameKey];
}

class Undefinedable<T> extends Optional<T> {
  bool _isUndefined = true;
  bool get isUndefined => _isUndefined;
  Undefinedable.of(T value) : super.of(value) {
    this._isUndefined = false;
  }
  Undefinedable.fromNullable(T value) : super.fromNullable(value);
  Undefinedable.absent() : super.absent();
}

