import 'package:quiver/collection.dart';


abstract class RelayObject<T> extends DelegatingMap<String, T> {
  Map<String, T> _data = {};
  @override
  Map<String, T> get delegate => _data;

  RelayObject([Map<String, T> data]) {
    _data = data == null ? {} : data;
  }

}

