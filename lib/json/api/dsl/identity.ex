defmodule JSON.API.DSL.Identity do
  import JSON.API.DSL.Instruction

  defmacro __using__(_) do
    quote do
      import JSON.API.DSL.Identity, only: [type: 1, id: 1]
      def id, do: {:fetch, :id}
      def type, do: {:use, ""}
      defoverridable id: 0, type: 0
    end
  end

  defmacro type(given) when is_binary(given) or is_atom(given) do
    quote do
      def type, do: {:use, unquote(given)}
    end
  end
  defmacro type(given) do
    quote do
      def type, do: unquote(translate_opts(given))
    end
  end

  defmacro id(given) when is_atom(given) do
    quote do
      def id, do: {:fetch, unquote(given)}
    end
  end
  defmacro id(given) do
    quote do
      def id, do: unquote(translate_opts(given))
    end
  end
end
