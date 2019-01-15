import 'dart:async';

import 'package:graphql_schema/graphql_schema.dart';

import 'package:anshi/src/graphql/graphql.dart';


abstract class Store {

  GraphQLSchema get schema;

  GraphQL get client;

  void register(String key, SubscriptionInfo subscriptionInfo);

  void removeSubscription(String key);

  Future<Map<String, dynamic>> commitMutation(String mutation);
}

class SubscriptionInfo<T> {
  final String query;
  final Sink<T> sink;

  SubscriptionInfo(this.query, this.sink);
}

class NaiveStore implements Store {

  GraphQL _client;
  final GraphQLSchema _schema;
  Map<String, SubscriptionInfo> _subscriptions = Map<String, SubscriptionInfo>();

  NaiveStore(this._schema) {
    this._client = GraphQL(schema);
  }

  @override
  GraphQL get client => _client;

  @override
  GraphQLSchema get schema => _schema;

  @override
  void register(String key, SubscriptionInfo subscriptionInfo) {
    assert(_subscriptions[key] == null);
    _subscriptions[key] = subscriptionInfo;
    print('register sink.hashCode: ${subscriptionInfo.sink.hashCode}');
  }

  @override
  void removeSubscription(String key) {
    _subscriptions.remove(key);
  }

  @override
  Future<Map<String, dynamic>> commitMutation(String mutation) async {
    final result = await this.client.parseAndExecute(mutation);
    final s = _subscriptions.values.toList().first;
    // _client.parseAndExecute(s.query).then((v) => s.sink.add(v));
    final x = await _client.parseAndExecute(s.query);
    print('x: $x \t sink: ${s.sink.hashCode}');
    s.sink.add(x);
    return result;
  }

}
