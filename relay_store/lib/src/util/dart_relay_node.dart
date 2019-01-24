import 'package:quiver/core.dart';
import 'package:quiver/collection.dart';


abstract class RelayObject extends DelegatingMap<String, dynamic> {
  Map<String, dynamic> _data = {};
  @override
  Map<String, dynamic> get delegate => _data;
}


abstract class DartRelayNode extends DelegatingMap<String, dynamic> {
  final Map<String, dynamic> _data = {};
  final Symbol kind;
  final List<String> _avaliableKeys;

  @override
  Map<String, dynamic> get delegate => _data;

  DartRelayNode(this.kind, this._avaliableKeys) {
    _data['kind'] = this.kind;
  }

  bool selfCheck() {
    final isVerified = _avaliableKeys.every((k) => _data.keys.contains(k));
    if (!isVerified) {
      throw 'Missing keys';
    }
    return isVerified;
  }
}
