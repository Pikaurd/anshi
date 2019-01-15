import 'dart:async';

import 'bloc_provider.dart';

class GraphQLBloc implements BlocBase {

  GraphQLBloc(this.query) {
    this._streamController = StreamController<dynamic>.broadcast();
  }

  StreamController<dynamic> _streamController;
  Stream<dynamic> get stream => _streamController.stream;
  Sink<dynamic> get sink => _streamController.sink;
  final String query;

  @override
  void dispose() {
    _streamController.close();
  }

}
