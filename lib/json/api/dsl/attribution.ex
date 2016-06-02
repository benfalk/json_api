defmodule JSON.API.DSL.Attribution do
  defmacro __using__(_) do
    quote do
      import JSON.API.DSL.Attribution, only: [attributes: 1]
      def attributes, do: []
      defoverridable [attributes: 0]
    end
  end

  defmacro attributes(attrs) do
    attr_opts = Enum.map(attrs, fn attr -> {attr, {:fetch, attr}} end)
    quote do
      def attributes, do: unquote(attr_opts)
    end
  end
end
