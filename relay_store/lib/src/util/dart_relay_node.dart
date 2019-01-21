import 'package:quiver/core.dart';
import 'package:quiver/collection.dart';


abstract class DartRelayNode<T> extends DelegatingMap<String, T> {
  final Map<String, dynamic> data = {};
  List<String> avaliableKeys = [];

  @override
  Map<String, T> get delegate => _validateBeforeGet();

  @override
  void operator[]=(String key, T value) {
    if (!validate(key, value)) throw 'illegal set';
    delegate[key] = value;
  }

  Map<String, T> _validateBeforeGet() {
    const isRelease = bool.fromEnvironment("dart.vm.product");
    if (isRelease) return data;
    _selfCheck();
    return data;
  }

  bool validate(String key, T value);
  void _selfCheck() {
    avaliableKeys.forEach((v) => {

    });
  }
}
