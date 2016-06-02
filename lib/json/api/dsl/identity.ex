defmodule JSON.API.DSL.Identity do
  defmacro __using__(_) do
    quote do
      import JSON.API.DSL.Identity, only: [type: 1]
      def id, do: {:fetch, :id}
      def type, do: {:use, ""}
      defoverridable id: 0, type: 0
    end
  end

  defmacro type(given) do
    quote do
      def type, do: {:use, unquote(given)}
    end
  end
end
