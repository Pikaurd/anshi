import 'package:quiver/collection.dart';


abstract class RelayObject extends DelegatingMap<String, dynamic> {
  Map<String, dynamic> _data = {};
  @override
  Map<String, dynamic> get delegate => _data;

  RelayObject([Map<String, dynamic> data]) {
    _data = data == null ? {} : data;
  }

}

