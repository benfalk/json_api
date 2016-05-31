defmodule JSON.API.Resource do

  @type attributes :: %{ atom() => any() }
  @type id :: String.t
  @type type :: String.t

  @type t :: %__MODULE__{
    id: id,
    type: type,
    attributes: attributes
  }

  defstruct id: "",
            type: "",
            attributes: %{}
  
  @spec build(module(), map(), any()) :: t
  def build(definition, data, context \\ nil) do
    %__MODULE__{
      id: get(definition.id, data, context) |> to_string,
      type: get(definition.type, data, context) |> to_string,
      attributes: fetch_attributes(definition, data, context)
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

  defp fetch_attributes(definition, data, context) do
    definition.attributes
    |> Enum.map(fn {attr, cmd} -> {attr, get(cmd, data, context)} end)
    |> Enum.into(%{})
  end
end
