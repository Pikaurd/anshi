import 'package:quiver/core.dart';

import '../store/helper_functions.dart';
import '../store/relay_store_types.dart';
import '../util/invariant.dart';
import './relay_record_source_mutator.dart';


class RelayRecordProxy implements RecordProxy {
  String _dataID;
  RelayRecordSourceMutator _mutator;
  RelayRecordProxy _source;

  RelayRecordProxy(this._source, this._mutator, this._dataID);

  @override
  void copyFieldsFrom(RecordProxy source) {
    // TODO: implement copyFieldsFrom
  }

  @override
  String getDataID() {
    // TODO: implement getDataID
    return null;
  }

  @override
  Optional<RecordProxy> getLinkedRecord(String name, [Optional<Variables> args]) {
    // TODO: implement getLinkedRecord
    return null;
  }

  @override
  Optional<List<Optional<RecordProxy>>> getLinkedRecords(String name, [Optional<Variables> args]) {
    // TODO: implement getLinkedRecords
    return null;
  }

  @override
  RecordProxy getOrCreateLinkedRecord(String name, String typeName, [Optional<Variables> args]) {
    // TODO: implement getOrCreateLinkedRecord
    return null;
  }

  @override
  String getType() {
    // TODO: implement getType
    return null;
  }

  @override
  getValue(String name, [Optional<Variables> args]) {
    // TODO: implement getValue
    return null;
  }

  @override
  RecordProxy setLinkedRecord(RecordProxy record, String name, [Optional<Variables> args]) {
    // TODO: implement setLinkedRecord
    return null;
  }

  @override
  RecordProxy setLinkedRecords(List<Optional<RecordProxy>> records, String name, [Optional<Variables> args]) {
    // TODO: implement setLinkedRecords
    return null;
  }

  @override
  RecordProxy setValue(value, String name, [Optional<Variables> args]) {
    // TODO: implement setValue
    return null;
  }

}
