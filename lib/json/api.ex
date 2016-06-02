defmodule JSON.API do
  defmacro __using__(_) do
    quote do
      use JSON.API.DSL
    end
  end

  def build_document(resource, data, context \\ nil) do
    %{
      links: %{},
      data: JSON.API.Resource.build(resource, data, context)
    }
  end
end
