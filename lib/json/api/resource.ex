defmodule JSON.API.Resource do
  alias JSON.API.Resource.Relationship

  defdelegate get(cmd, data, context), to: JSON.API.Instruction, as: :run

  @type attributes :: %{ atom() => any() }
  @type id :: String.t
  @type relationships :: %{ atom() => Relationship.t }
  @type type :: String.t
  @type identity :: %{ :id => String.t, :type => String.t }

  @type t :: %__MODULE__{
    id: id,
    type: type,
    attributes: attributes,
    relationships: relationships
  }

  defstruct id: "",
            type: "",
            attributes: %{},
            relationships: %{}
  
  @spec build(module(), map(), any()) :: t
  def build(definition, data, context \\ nil) do
    %__MODULE__{
      id: get(definition.id, data, context) |> to_string,
      type: get(definition.type, data, context) |> to_string,
      attributes: attributes(definition, data, context),
      relationships: relationships(definition, data, context)
    }
  end

  @spec identity(module(), map(), any()) :: identity
  def identity(definition, data, context \\ nil) do
    %{
      id: get(definition.id, data, context) |> to_string,
      type: get(definition.type, data, context) |> to_string
    }
  end

  @spec from_opts(Keyword.t) :: map()
  def from_opts(opts) do
    %{
      id: Keyword.get(opts, :id, {:fetch, :id}),
      type: Keyword.get(opts, :type,  {:use, ""}),
      attributes: Keyword.get(opts, :attributes, []),
      relationships: Keyword.get(opts, :relationships, [])
    }
  end

  defp relationships(definition, data, context) do
    definition.relationships
    |> Enum.map(fn rel -> {rel.name, Relationship.expand(rel, data, context)} end)
    |> Enum.into(%{})
  end

  defp attributes(definition, data, context) do
    definition.attributes
    |> Enum.map(fn {attr, cmd} -> {attr, get(cmd, data, context)} end)
    |> Enum.into(%{})
  end
end
