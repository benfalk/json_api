defmodule JSON.API.DSL.Relationship do
  alias JSON.API.Resource.Relationship

  defmacro __using__(_) do
    quote do
      import JSON.API.DSL.Relationship, only: [has_many: 2, has_one: 2]
      @relationships []
      @before_compile JSON.API.DSL.Relationship
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def relationships, do: @relationships
      defoverridable relationships: 0
    end
  end

  defmacro has_many(field, opts) do
    opts = opts
    |> Keyword.put(:type, :to_many)
    |> Keyword.put(:name, field)

    quote bind_quoted: [opts: opts] do
      @relationships [Relationship.from_opts(opts) | @relationships]
    end
  end

  defmacro has_one(field, opts \\ []) do
    opts = opts
    |> Keyword.put(:type, :to_one)
    |> Keyword.put(:name, field)

    quote bind_quoted: [opts: opts] do
      @relationships [Relationship.from_opts(opts) | @relationships]
    end
  end
end
