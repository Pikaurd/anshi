import 'dart:collection';
import 'package:quiver/core.dart';

import 'package:relay_store/src/store/relay_record_state.dart';

import './relay_store_types.dart';

class RelayInMemoryRecordSource implements MutableRecordSource {
  RecordMap _records;

  RelayInMemoryRecordSource([RecordMap records]) {
    var optionalRecords = Optional.fromNullable(records);
    this._records = optionalRecords.or(RecordMap());
  }

  @override
  void clear() {
    this._records.clear();
  }

  @override
  void delete(String dataID) {
    this._records[dataID] = null;
  }

  @override
  Optional<Record> get(String dataID) {
    return this._records[dataID];
  }

  @override
  List<String> getRecordIDs() {
    return this._records.keys;
  }

  @override
  RecordState getStatus(String dataID) {
    if (this._records.containsKey(dataID)) {
      return this._records[dataID] == null ? RecordState.nonexistent : RecordState.existent;
    }
    return RecordState.unknown;
  }

  @override
  bool has(String dataID) {
    return this._records.containsKey(dataID);
  }

  @override
  void load(String dataID, callback) {
    callback(null, this.get(dataID));
  }

  @override
  void remove(String dataID) {
    this._records.remove(dataID);
  }

  @override
  void set(String dataID, Record record) {
    this._records[dataID] = Optional.of(record);
  }

  @override
  int size() {
    return this._records.keys.length;
  }

  Map<String, dynamic> toJSON() {
    return this._records;
  }

}