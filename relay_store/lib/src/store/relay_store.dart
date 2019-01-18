import 'dart:collection';

import 'package:quiver/core.dart';

import './relay_store_types.dart';

abstract class Subscription {
  Function(Snapshot snapshot) callback;
  Snapshot snapshot;
}

class RelayStore implements Store {

  Scheduler _gcScheduler;
  bool _hasScheduledGC;
  int _index;
  Optional<OperationLoader> _operationLoader;
  MutableRecordSource _recordSource;
  Map<int, NormalizationSelector> _roots;
  Set<Subscription> _subscriptions;
  Map<String, bool> _updatedRecordIDs;
  int _gcHoldCounter;
  bool _shouldScheduleGC;

  RelayStore(
    MutableRecordSource source, 
    Scheduler gcScheduler, 
    Optional<OperationLoader> operationLoader
  ) 
  {
    if (!bool.fromEnvironment("dart.vm.product")) { // dev mode

    }
    this._gcScheduler = gcScheduler;
    this._hasScheduledGC = false;
    this._index = 0;
    this._operationLoader = operationLoader;
    this._recordSource = source;
    this._roots = {};
    this._subscriptions = HashSet();
    this._updatedRecordIDs = {};
    this._gcHoldCounter = 0;
    this._shouldScheduleGC = false;
  }

  @override
  bool check(NormalizationSelector selector) {
    // TODO: implement check
    return null;
  }

  @override
  RecordSource getSource() {
    return _recordSource;
  }

  @override
  Snapshot lookup(ReaderSelector selector) {
    // TODO: implement lookup
    return null;
  }

  @override
  void notify() {
    // TODO: implement notify
  }

  @override
  void publish(RecordSource source) {
    // TODO: implement publish
  }

  @override
  Disposable subscribe(Snapshot snapshot, callback) {
    // TODO: implement subscribe
    return null;
  }

}
