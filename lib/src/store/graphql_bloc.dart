import 'dart:async';

import 'bloc_provider.dart';
import '../store/store.dart';

class GraphQLBloc implements BlocBase {

  GraphQLBloc(this.query, this._store, this._subscriptionKey) {
    this._streamController = StreamController<dynamic>.broadcast();
    final String key = '${this._subscriptionKey}:${new DateTime.now().millisecondsSinceEpoch}';
    this._store.register(key, SubscriptionInfo(this.query, _sink));
    executeQuery();
  }

  StreamController<dynamic> _streamController;
  Stream<dynamic> get stream => _streamController.stream;
  Sink<dynamic> get _sink => _streamController.sink;
  final String query;
  final Store _store;
  final String _subscriptionKey;

  @override
  void dispose() {
    _streamController.close();
    _store.removeSubscription(_subscriptionKey);
  }

  void executeQuery() {
    this._store.client.parseAndExecute(this.query).then((v) => this._sink.add(v));
  }

}
