defmodule Absinthe.Serializer do
  alias Absinthe.Language.{
    Argument,
    BooleanValue,
    Document,
    EnumTypeDefinition,
    EnumValue,
    Field,
    FloatValue,
    Fragment,
    FragmentSpread,
    InlineFragment,
    IntValue,
    ListValue,
    NamedType,
    NonNullType,
    NullValue,
    ObjectField,
    ObjectValue,
    OperationDefinition,
    SelectionSet,
    StringValue,
    Variable,
    VariableDefinition
  }

  def serialize(%Document{} = document) do
    document.definitions
    |> Enum.map(&serialize/1)
    |> Enum.join("\n")
  end

  def serialize(
        %OperationDefinition{
          name: name,
          operation: operation,
          variable_definitions: variable_definitions,
          selection_set: selection_set
        } = od
      ) do
    variables_string =
      variable_definitions
      |> Enum.map(&serialize/1)

    """
    #{to_string(operation)} #{to_string(name)} #{serialize(selection_set)}
    """
  end

  def serialize(%EnumTypeDefinition{}) do
  end

  def serialize(%Fragment{
        name: name,
        selection_set: selection_set,
        type_condition: type_condition
      }) do
    "fragment #{name} on #{serialize(type_condition)} #{serialize(selection_set)}"
  end

  def serialize(%InlineFragment{
        selection_set: selection_set,
        type_condition: type_condition
      }) do
    "... on #{serialize(type_condition)} #{serialize(selection_set)}"
  end

  def serialize(%Argument{name: name, value: value}) do
    "#{name}: #{serialize(value)}"
  end

  def serialize(
        %VariableDefinition{type: type, variable: variable, default_value: default_value} = vd
      ) do
    result = "#{serialize(variable)}: #{serialize(type)}"
    if default_value, do: result <> " = #{serialize(default_value)}", else: result
  end

  def serialize(%Field{name: name, selection_set: nil}), do: name

  def serialize(%Field{name: name, arguments: arguments, selection_set: selection_set}) do
    argument_string =
      if arguments == [] do
        ""
      else
        "(#{arguments |> Enum.map(&serialize/1) |> Enum.join(", ")})"
      end

    "#{name}#{argument_string} #{serialize(selection_set)}"
  end

  def serialize(%SelectionSet{selections: selections}) do
    selection_string =
      selections
      |> Enum.map(&serialize/1)
      |> Enum.join("\n")

    """
    {
    #{selection_string}
    }
    """
  end

  def serialize(%ListValue{values: values}) do
    values_string =
      values
      |> Enum.map(&serialize/1)
      |> Enum.join(", ")

    "[#{values_string}]"
  end

  def serialize(%ObjectValue{fields: fields}) do
    fields_string =
      fields
      |> Enum.map(&serialize/1)
      |> Enum.join(", ")

    "{#{fields_string}}"
  end

  def serialize(%ObjectField{name: name, value: value}) do
    "#{name}: #{serialize(value)}"
  end

  def serialize(%NonNullType{type: type}), do: "#{serialize(type)}!"
  def serialize(%Variable{name: name}), do: "$#{name}"
  def serialize(%NamedType{name: name}), do: name
  def serialize(%IntValue{value: value}), do: value
  def serialize(%FloatValue{value: value}), do: value
  def serialize(%StringValue{value: value}), do: value
  def serialize(%BooleanValue{value: value}), do: value
  def serialize(%EnumValue{value: value}), do: value
  def serialize(%EnumValue{value: value}), do: value
  def serialize(%NullValue{}), do: "null"
  def serialize(%FragmentSpread{name: name}), do: "...#{name}"
end
