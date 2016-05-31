defmodule JSON.API do
  defmacro __using__(_) do
    quote do
      import JSON.API, only: [
        has_many: 2,
        has_one: 2,
        attributes: 1,
        type: 1
      ]
      def id, do: {:fetch, :id}
      def type, do: {:use, ""}
      def attributes, do: []
      defoverridable id: 0, type: 0, attributes: 0
    end
  end

  defmacro has_many(field, opts \\ []) do
  end

  defmacro has_one(field, opts \\ []) do
  end

  defmacro attributes(attrs) do
    attr_opts = Enum.map(attrs, fn attr -> {attr, {:fetch, attr}} end)
    quote do
      def attributes, do: unquote(attr_opts)
    end
  end

  defmacro type(given) do
    quote do
      def type, do: {:use, unquote(given)}
    end
  end

  def build_document(resource, data, context \\ nil) do
    %{
      links: %{},
      data: JSON.API.Resource.build(resource, data, context)
    }
  end
end
