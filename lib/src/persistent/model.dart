import 'package:anshi/src/persistent/field.dart';
import 'package:anshi/src/persistent/operation.dart';

abstract class BaseModel extends Field {

  BaseModel(FieldType type, String identifier): super(type, identifier);

  List<Field> fields();

  void update(Operation operation);

  void notify();
}


