import 'package:quiver/core.dart';

import './relay_store_types.dart';
import './relay_store_utils.dart';
import '../util/invariant.dart';


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

class Undefinedable<T> extends Optional<T> {
  bool _isUndefined = true;
  bool get isUndefined => _isUndefined;
  Undefinedable.of(T value) : super.of(value) {
    this._isUndefined = false;
  }
  Undefinedable.fromNullable(T value) : super.fromNullable(value);
  Undefinedable.absent() : super.absent();
}

