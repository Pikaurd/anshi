import 'package:quiver/collection.dart';

class Record {}

class RecordStore extends DelegatingMap<String, Record> {
  final Map<String, Record> _records = {};

  Map<String, Record> get delegate => _records;
}

