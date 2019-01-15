import 'package:anshi/src/persistent/field.dart';

class Operation {
  final OperationMethod method;
  final List<Field> affectedField;

  const Operation(OperationMethod method, [List<Field> affectedField]):
    this.method = method,
    this.affectedField = affectedField == null ? const [] : affectedField;
}

enum OperationMethod { 
  add, remove, modify
}
