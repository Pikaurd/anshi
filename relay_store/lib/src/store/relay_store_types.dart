import 'package:quiver/collection.dart';
import 'package:quiver/core.dart';

import './relay_record_state.dart';
import '../util/normalization_node.dart';

typedef Scheduler = void Function(void Function(void));

abstract class RecordSource {
  Optional<Record> get(String dataID);
  List<String> getRecordIDs();
  RecordState getStatus(String dataID);
  bool has(String dataID);
  void load(String dataID, Function(Error error, Record record) callback);
  int size();
}

abstract class MutableRecordSource extends RecordSource {
  void clear();
  void delete(String dataID);
  void remove(String dataID);
  void set(String dataID, Record record);
}

class Record extends DelegatingMap<String, dynamic> {
  final Map<String, dynamic> _record = {};

  @override
  Map<String, dynamic> get delegate => _record;
}

class Variables extends DelegatingMap<String, dynamic> {
  final Map<String, dynamic> _recordMap = {};

  @override
  Map<String, dynamic> get delegate => _recordMap;
}

abstract class Store {
  RecordSource getSource();
  bool check(NormalizationSelector selector);
  Snapshot lookup(ReaderSelector selector);
  void notify();
  void publish(RecordSource source);
  Disposable subscribe(Snapshot snapshot, Function(Snapshot snapshot) callback);
}

abstract class Disposable {
  void dispose();
}

abstract class NormalizationSelector<TNormalizationNode> {
  String dataID;
  TNormalizationNode node;
  Variables variables;
}

abstract class ReaderSelector<TReaderNode> {
  String dataID;
  TReaderNode readerNode;
  Variables variables;
}

abstract class Snapshot<TReaderNode> extends ReaderSelector<TReaderNode> {
  Optional<SelectorData> data;
  RecordMap seenRecords;
  bool isMissingData;
}

class SelectorData extends DelegatingMap<String, dynamic> {
  final Map<String, dynamic> _data = {};

  @override
  Map<String, dynamic> get delegate => _data;
}

class RecordMap extends DelegatingMap<String, Optional<Record>> {
  final Map<String, Optional<Record>> _recordMap = {};

  @override
  Map<String, Optional<Record>> get delegate => _recordMap;
}

abstract class OperationLoader {
  // FIXME: not implement
}

abstract class MissingFieldHandler<FieldType, ReturnType> {
  final Symbol kind;
  ReturnType handle(FieldType field, Optional<Record> record, Variables args, ReadOnlyRecordSourceProxy store);

  MissingFieldHandler(this.kind);
}

abstract class ScalarFieldHandler extends MissingFieldHandler<NormalizationScalarField, dynamic> {
  ScalarFieldHandler() : super(#scalar);
}

abstract class LinkedFieldHandler extends MissingFieldHandler<NormalizationLinkedField, Optional<String>> {
  LinkedFieldHandler() : super(#linked);
}

abstract class LinkedFieldsHandler extends MissingFieldHandler<NormalizationLinkedField, Optional<List<Optional<String>>>> {
  LinkedFieldsHandler() : super(#plural_linked);
}

/**
 * An interface for imperatively getting/setting properties of a `Record`. This interface
 * is designed to allow the appearance of direct Record manipulation while
 * allowing different implementations that may e.g. create a changeset of
 * the modifications.
 */
abstract class RecordProxy {
  void copyFieldsFrom(RecordProxy source);
  String getDataID();
  Optional<RecordProxy> getLinkedRecord(String name, [Optional<Variables> args]);
  Optional<List<Optional<RecordProxy>>> getLinkedRecords(String name, [Optional<Variables> args]);
  RecordProxy getOrCreateLinkedRecord(String name, String typeName, [Optional<Variables> args]);
  String getType();
  dynamic getValue(String name, [Optional<Variables> args]);
  RecordProxy setLinkedRecord(RecordProxy record, String name, [Optional<Variables> args]);
  RecordProxy setLinkedRecords(List<Optional<RecordProxy>> records, String name, [Optional<Variables> args]);
  RecordProxy setValue(dynamic value, String name, [Optional<Variables> args]);
}

abstract class ReadOnlyRecordProxy {
  String getDataID();
  Optional<RecordProxy> getLinkedRecord(String name, [Optional<Variables> args]);
  Optional<List<Optional<RecordProxy>>> getLinkedRecords(String name, [Optional<Variables> args]);
  RecordProxy getOrCreateLinkedRecord(String name, String typeName, [Optional<Variables> args]);
  String getType();
}

/**
 * An interface for imperatively getting/setting properties of a `RecordSource`. This interface
 * is designed to allow the appearance of direct RecordSource manipulation while
 * allowing different implementations that may e.g. create a changeset of
 * the modifications.
 */
abstract class RecordSourceProxy {
  RecordProxy create(String dataID, String typeName);
  void delete(String dataID);
  Optional<RecordProxy> get(String dataID);
  RecordProxy getRoot();
}

abstract class ReadOnlyRecordSourceProxy {
  Optional<ReadOnlyRecordProxy> get(String dataID);
  ReadOnlyRecordProxy getRoot();
}

