
import 'package:built_collection/built_collection.dart';
import 'package:quiver/core.dart';

/*



export type ReaderSelectableNode = ReaderFragment | ReaderSplitOperation;
 */

abstract class ReaderArgument implements ReaderSelectableNode {
  final Symbol kind;
  String name;
  Optional<String> type;

  ReaderArgument(this.kind);
}

abstract class ReaderLiteral extends ReaderArgument {
  dynamic value;

  ReaderLiteral() : super(#literal);
}

abstract class ReaderVariable extends ReaderArgument {
  String varibaleName;
  
  ReaderVariable() : super(#varibale);
}

/*
export type ReaderArgumentDefinition = ReaderLocalArgument | ReaderRootArgument;
*/
abstract class ReaderArgumentDefinition {
  final Symbol kind;
  String name;
  Optional<String> type;

  ReaderArgumentDefinition(this.kind);
}

abstract class ReaderLocalArgument extends ReaderArgumentDefinition {
  dynamic defaultValue;
  ReaderLocalArgument() : super(#local_argument);
}

abstract class ReaderRootArgument extends ReaderArgumentDefinition {
  ReaderRootArgument() : super(#root_argument);
}

/*
export type ReaderField =
  // | ReaderScalarField
  // | ReaderLinkedField
  // | ReaderMatchField;
 */
abstract class ReaderField implements ReaderSelection {
  final Symbol kind;
  Optional<String> alias;
  String name;
  BuiltList<Optional<ReaderArgument>> args;
  Optional<String> storangeKey;

  ReaderField(this.kind);
}

abstract class ReaderScalarField extends ReaderField {
  ReaderScalarField() : super(#scalar_field);
}

abstract class ReaderLinkedField extends ReaderField implements ReaderNode {
  Optional<String> concreteType;
  bool plural;
  ReaderLinkedField() : super(#linked_field);
}

abstract class ReaderMatchField extends ReaderField {
  Map<String, ReaderMatchFieldType> matchesByType;

  ReaderMatchField() : super(#match_field);
}

class ReaderMatchFieldType {
  String fragmentPropName;
  String fragmentName;
}

/*
export type ReaderNode =
  // | ReaderCondition
  // | ReaderLinkedField
  // | ReaderFragment
  // | ReaderInlineFragment
  // | ReaderSplitOperation;
 */
abstract class ReaderNode {
  final Symbol kind;
  BuiltList<ReaderSelection> selections;
  ReaderNode(this.kind);
}

abstract class ReaderCondition extends ReaderNode implements ReaderSelection {
  bool passingValue;
  String condition;
  ReaderCondition() : super(#condition);
}

abstract class ReaderFragment extends ReaderNode implements ReaderSelection {
  String name;
  String type;
  BuiltList<ReaderArgumentDefinition> argumentDefinitions;
  Optional<Map<String, ReaderFragmentMetadata>> metadata;

  ReaderFragment() : super(#fragment);
}

class ReaderFragmentMetadata {
  Optional<BuiltList<dynamic>> connection;
  Optional<bool> mask;
  Optional<bool> plural;
  Optional<dynamic> refetchOperation;
}

abstract class ReaderInlineFragment extends ReaderNode implements ReaderSelection {
  String type;
  ReaderInlineFragment() : super(#inline_fragment);
}

abstract class ReaderSplitOperation extends ReaderNode implements ReaderSelectableNode {
  ReaderSplitOperation() : super(#split_operation);
}

/*
export type ReaderSelection =
  // | ReaderCondition
  // | ReaderField
  // | ReaderFragmentSpread
  // | ReaderInlineFragment
  | ReaderMatchField;
 */
abstract class ReaderSelection {
  final Symbol kind;

  ReaderSelection(this.kind);
}

abstract class ReaderFragmentSpread extends ReaderSelection {
  String name;
  Optional<BuiltList<ReaderArgumentDefinition>> argumentDefinitions;
  ReaderFragmentSpread() : super(#fragment_spread);
}

/*
export type ReaderSelectableNode = ReaderFragment | ReaderSplitOperation;
*/

abstract class ReaderSelectableNode {
  final Symbol kind;
  String name;
  BuiltList<ReaderSelection> selections;

  ReaderSelectableNode(this.kind);
}
