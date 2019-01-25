import 'package:quiver/core.dart';

const __DEV__ = !bool.fromEnvironment("dart.vm.product");

void invariant(dynamic condition, String message) {
  if (!__DEV__) return;

  final nullableCondition = Optional.fromNullable(condition);
  if (nullableCondition.isEmpty || nullableCondition.value == false) {
    throw message;
  }
}

void warning(dynamic condition, String message) {
  if (!__DEV__) return;

  final nullableCondition = Optional.fromNullable(condition);
  if (nullableCondition.isEmpty || nullableCondition.value == false) {
    print('[WARN]\t$message');
  }
}
