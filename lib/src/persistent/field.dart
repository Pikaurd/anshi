
class Field {
  final FieldType type;
  final String identifier;

  Field(this.type, this.identifier);
}

enum FieldType {
  scalar, field
}
