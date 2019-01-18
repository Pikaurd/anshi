
import 'package:built_collection/built_collection.dart';
import 'package:quiver/core.dart';

/**
 export type NormalizationHandle =
  | NormalizationScalarHandle
  | NormalizationLinkedHandle;
 */
abstract class NormalizationHandle implements NormalizationSelection {
  final Symbol kind;
  Optional<String> alias;
  String name;
  Optional<BuiltList<NormalizationArgument>> args;
  String handle;
  String key;
  Optional<BuiltList<String>> filters;

  NormalizationHandle(this.kind);
}

/**
 export type NormalizationArgument =
  | NormalizationLiteral
  | NormalizationVariable;
 */
abstract class NormalizationArgument {
   final Symbol kind;
   String name;
   Optional<String> type;

   NormalizationArgument(this.kind);
}

/**
 export type NormalizationArgumentDefinition =
  | NormalizationLocalArgument
  | NormalizationRootArgument;
 */
abstract class NormalizationArgumentDefinition {
  final Symbol kind;
  String name;
  String type;

  NormalizationArgumentDefinition(this.kind);
}

/**
 export type NormalizationField =
  | NormalizationScalarField
  | NormalizationLinkedField
  | NormalizationMatchField;
 */
abstract class NormalizationField implements NormalizationSelection {
  final Symbol kind;
  String name;
  BuiltList<NormalizationArgument> args;
  Optional<String> storangeKey;

  NormalizationField(this.kind);
}


/** 
 export type NormalizationNode =
  | NormalizationCondition
  | NormalizationLinkedField
  | NormalizationInlineFragment
  | NormalizationOperation
  | NormalizationSplitOperation;
 */
abstract class NormalizationNode {
  final Symbol kind;
  BuiltList<NormalizationSelection> selections;

  NormalizationNode(this.kind);
}

/** TODO
 export type NormalizationSelection =
  | NormalizationCondition
  | NormalizationField
  | NormalizationHandle
  | NormalizationInlineFragment
  | NormalizationMatchField
 */
abstract class NormalizationSelection {
  final Symbol kind;

  NormalizationSelection(this.kind);
}

/**
 export type NormalizationSelectableNode =
  | NormalizationOperation
  | NormalizationSplitOperation;
 */
abstract class NormalizationSelectableNode {
  final Symbol kind;

  NormalizationSelectableNode(this.kind);
}



class NormalizationLiteral extends NormalizationArgument {
  NormalizationLiteral() : super(#literal);
  dynamic value;
}

class NormalizationVariable extends NormalizationArgument {
  NormalizationVariable () : super(#variable);
  String varibaleName;
}

class NormalizationScalarField extends NormalizationField implements NormalizationSelection {
  Optional<String> alias;

  NormalizationScalarField() : super(#scalar_field);
}

class NormalizationLinkedField extends NormalizationField implements NormalizationNode {
  Optional<String> alias;
  Optional<String> concreteType;
  bool plural;
  BuiltList<NormalizationSelection> selections;

  NormalizationLinkedField() : super(#linked_field);
}

class NormalizationMatchField extends NormalizationField implements NormalizationSelection {
  Map<String, NormalizationMatchFieldType> matchesByType;

  NormalizationMatchField() : super(#match_field);
}

class NormalizationMatchFieldType {
  String fragmentPropName;
  String fragmentName;
}

class NormalizationOperation extends NormalizationNode implements NormalizationSelectableNode {
  String name;
  BuiltList<NormalizationLocalArgument> argumentDefinitions;
  BuiltList<NormalizationSelection> selections;
  
  NormalizationOperation() : super(#operation);
}

class NormalizationCondition extends NormalizationNode implements NormalizationSelection {
  bool passingValue;
  String condition;
  BuiltList<NormalizationSelection> selections;
  
  NormalizationCondition() : super(#condition);
}

class NormalizationScalarHandle extends NormalizationHandle {
  NormalizationScalarHandle() : super(#scalar_handle);
}

class NormalizationLinkedHandle extends NormalizationHandle {
  NormalizationLinkedHandle() : super(#linked_handle);
}

class NormalizationLocalArgument extends NormalizationArgument {
  dynamic defaultValue;

  NormalizationLocalArgument() : super(#local_argument);
}

class NormalizationRootArgument extends NormalizationArgument {
  NormalizationRootArgument() : super(#root_argument);
}

class NormalizationInlineFragment extends NormalizationNode implements NormalizationSelection {
  String type;

  NormalizationInlineFragment() : super(#inline_fragment);
}
