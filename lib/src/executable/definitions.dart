import 'package:meta/meta.dart';
import 'package:gql/ast.dart';
import 'package:built_graphql/src/schema/definitions/definitions.dart';

part 'selections.dart';

@immutable
abstract class ExecutableGraphQLEntity extends GraphQLEntity {
  const ExecutableGraphQLEntity();
}

@immutable
class _Executable extends ExecutableGraphQLEntity implements TypeResolver {
  const _Executable([ResolveType getType])
      : getType = getType ?? TypeResolver.withoutContext,
        super();

  @override
  final ResolveType getType;

  @override
  Node get astNode => throw UnimplementedError();
}

@immutable
abstract class ExecutableDefinition extends _Executable {
  const ExecutableDefinition([ResolveType getType]) : super(getType);

  @override
  ExecutableDefinitionNode get astNode;

  String get name => astNode.name.value;

  static ExecutableDefinition fromNode(ExecutableDefinitionNode astNode) {
    if (astNode is OperationDefinitionNode) {
      return OperationDefinition.fromNode(astNode);
    }
    if (astNode is FragmentDefinitionNode) {
      return FragmentDefinition.fromNode(astNode);
    }

    throw ArgumentError('$astNode is unsupported');
  }
}

@immutable
class OperationDefinition extends ExecutableDefinition {
  const OperationDefinition(
    this.astNode, [
    ResolveType getType,
  ]) : super(getType);

  @override
  final OperationDefinitionNode astNode;

  OperationType get type => astNode.type;

  List<VariableDefinition> get variables =>
      astNode.variableDefinitions.map(VariableDefinition.fromNode).toList();

  SelectionSet get selectionSet => SelectionSet(
        astNode.selectionSet,
        getType(type.name) as ObjectTypeDefinition,
        getType,
      );

  static OperationDefinition fromNode(
    OperationDefinitionNode astNode, [
    ResolveType getType,
  ]) =>
      OperationDefinition(astNode, getType);
}

@immutable
class FragmentDefinition extends ExecutableDefinition {
  const FragmentDefinition(this.astNode, [ResolveType getType])
      : super(getType);

  @override
  final FragmentDefinitionNode astNode;

  TypeCondition get _typeCondition =>
      TypeCondition.fromNode(astNode.typeCondition);

  TypeDefinition get onType => getType(_typeCondition.on.name);

  List<Directive> get directives =>
      astNode.directives.map(Directive.fromNode).toList();

  SelectionSet get selectionSet =>
      SelectionSet(astNode.selectionSet, onType, getType);

  static FragmentDefinition fromNode(
    FragmentDefinitionNode astNode, [
    ResolveType getType,
  ]) =>
      FragmentDefinition(astNode, getType);
}

@immutable
class TypeCondition extends ExecutableGraphQLEntity {
  const TypeCondition(this.astNode);

  @override
  final TypeConditionNode astNode;

  NamedType get on => NamedType.fromNode(astNode.on);

  static TypeCondition fromNode(TypeConditionNode astNode) =>
      TypeCondition(astNode);
}

@immutable
class VariableDefinition extends ExecutableGraphQLEntity {
  const VariableDefinition(this.astNode);

  @override
  final VariableDefinitionNode astNode;

  Variable get variable => Variable.fromNode(astNode.variable);

  GraphQLType get type => GraphQLType.fromNode(astNode.type);

  DefaultValue get defaultValue => DefaultValue.fromNode(astNode.defaultValue);

  List<Directive> get directives =>
      astNode.directives.map(Directive.fromNode).toList();

  static VariableDefinition fromNode(VariableDefinitionNode astNode) =>
      VariableDefinition(astNode);
}