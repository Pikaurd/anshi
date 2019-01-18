import 'package:quiver/core.dart';

void invariant(dynamic condition, String message) {
  const isRelease = bool.fromEnvironment("dart.vm.product");
  if (isRelease) return;

  final nullableCondition = Optional.fromNullable(condition);
  if (nullableCondition.isEmpty || nullableCondition.value == false) {
    throw message;
  }
}