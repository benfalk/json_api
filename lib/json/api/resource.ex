defmodule JSON.API.Resource do
  alias JSON.API.Resource.Relationship

  @type attributes :: %{ atom() => any() }
  @type id :: String.t
  @type relationships :: %{ atom() => Relationship.t }
  @type type :: String.t

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

  defp get({:fetch, key}, data, _), do: Map.get(data, key)
  defp get({:use, value}, _, _), do: value
  defp get(key, data, context) when is_function(key) do
    case :erlang.fun_info(key, :arity) do
      {:arity, 0} -> key.()
      {:arity, 1} -> key.(data)
      {:arity, 2} -> key.(data, context)
    end
  end

  defp relationships(definition, _data, _context) do
    definition.relationships
    |> Enum.map(fn rel -> {rel.name, %{}} end)
    |> Enum.into(%{})
  end

  defp attributes(definition, data, context) do
    definition.attributes
    |> Enum.map(fn {attr, cmd} -> {attr, get(cmd, data, context)} end)
    |> Enum.into(%{})
  end
end
