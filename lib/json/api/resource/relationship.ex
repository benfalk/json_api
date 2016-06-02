defmodule JSON.API.Resource.Relationship do
  @moduledoc """
  This module is responsible for representing the relationships between resources
  and provides functionality to build the `relations object` described in the spec.

  http://jsonapi.org/format/#document-resource-object-relationships
  """

  alias JSON.API.Resource

  @default_resource Resource.Default
  @default_type :to_one
  
  @type name :: atom()
  @type resource :: module()
  @type type :: :to_one | :to_many
  @type data_strategy :: :default

  @type t :: %__MODULE__{
    type: type,
    resource: resource,
    name: name,
    using: data_strategy
  }

  
  defstruct type: @default_type,
            resource: @default_resource,
            name: nil,
            using: :default
  
  @spec default_resource() :: resource
  def default_resource, do: @default_resource

  @spec from_opts(Keyword.t) :: t
  def from_opts(opts) do
    %__MODULE__{
      name: Keyword.fetch!(opts, :name),
      type: Keyword.get(opts, :type, @default_type),
      resource: Keyword.get(opts, :resource, @default_resource)
    }
  end

  @spec expand(t, map(), any()) :: map()
  def expand(relation, data, context) do
    %{}
    |> add_data(relation, data, context)
  end

  defp add_data(map, rel, data, context) do
    put_in(map, [:data], relation_data(rel, data, context))
  end

  defp relation_data(%{type: :to_one, using: :default}=rel, data, context) do
    case Map.get(data, rel.name, nil) do
      nil -> nil
      rel_data -> Resource.identity(rel.resource, rel_data, context)
    end
  end
  defp relation_data(%{type: :to_many, using: :default}=rel, data, context) do
    case Map.get(data, rel.name, []) do
      data when not is_list(data) -> []
      rel_data ->
        rel_data
        |> Enum.map(&Resource.identity(rel.resource, &1, context))
    end
  end
end
