defmodule JSON.API.Resource.Relationship do
  @moduledoc """
  This module is responsible for representing the relationships between resources
  and provides functionality to build the `relations object` described in the spec.

  http://jsonapi.org/format/#document-resource-object-relationships
  """

  alias JSON.API.Resource

  @default_resource Resource.Default
  @default_type :to_one
  @default_strategy :default
  
  @type name :: atom()
  @type resource :: module()
  @type type :: :to_one | :to_many
  @type data_strategy :: :default | {:fetch, atom()} | {:use, atom()}

  @type t :: %__MODULE__{
    type: type,
    resource: resource,
    name: name,
    using: data_strategy
  }

  
  defstruct type: @default_type,
            resource: @default_resource,
            name: nil,
            owner: nil,
            using: @default_strategy
  
  @spec default_resource() :: resource
  def default_resource, do: @default_resource

  @spec from_opts(Keyword.t) :: t
  def from_opts(opts) do
    %__MODULE__{
      name: Keyword.fetch!(opts, :name),
      owner: Keyword.fetch!(opts, :owner),
      type: Keyword.get(opts, :type, @default_type),
      resource: Keyword.get(opts, :resource, @default_resource),
      using: Keyword.get(opts, :using, @default_strategy)
    }
  end

  @spec data(t, map(), any()) :: map() | [map()]
  def data(rel, data, context \\ nil), do: rel_data(rel, data, context)

  @spec expand(t, map(), any()) :: map()
  def expand(relation, data, context) do
    %{}
    |> add_data(relation, data, context)
  end

  defp add_data(map, relation, data, context) do
    rel_data =
      case data(relation, data, context) do
        rel when is_list(rel) ->
          Enum.map(rel, &Resource.identity(relation.resource, &1, context))

        rel when is_map(rel) ->
          Resource.identity(relation.resource, rel, context)

        nil -> nil
      end
    put_in(map, [:data], rel_data)
  end

  defp rel_data(%{type: :to_one, using: :default}=rel, data, _) do
    Map.get(data, rel.name, nil)
  end
  defp rel_data(%{type: :to_one, using: {:fetch, what}}, data, _) do
    Map.get(data, what, nil)
  end
  defp rel_data(%{type: :to_many, using: :default}=rel, data, _) do
    case Map.get(data, rel.name, []) do
      rel_data when not is_list(rel_data) -> []
      rel_data -> rel_data
    end
  end
  defp rel_data(%{type: :to_many, using: {:fetch, what}}, data, _) do
    case Map.get(data, what, []) do
      rel_data when not is_list(rel_data) -> []
      rel_data -> rel_data
    end
  end
end
