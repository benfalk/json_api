defmodule JSON.API.Resource.Relationship do

  @default_resource JSON.API.Resource.Default
  @default_type :has_one
  
  @type name :: atom()
  @type resource :: module()
  @type type :: :has_one | :has_many

  @type t :: %__MODULE__{
    type: type,
    resource: resource,
    name: name
  }
  
  defstruct type: @default_type,
            resource: @default_resource,
            name: nil
  
  @spec default_resource() :: resource
  def default_resource, do: @default_resource

  def build(name, opts) do
    %__MODULE__{
      name: name,
      type: Keyword.get(opts, :type, @default_type),
      resource: Keyword.get(opts, :resource, @default_resource)
    }
  end
end
