defmodule JSON.API.DSL.Relationship do
  alias JSON.API.Resource.Relationship
  import FunkyFunc

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
    |> escape_fun_list
    |> transform_opts(field)
    |> Keyword.put(:type, :to_many)
    |> Keyword.put(:name, field)

    quote bind_quoted: [opts: opts] do
      @relationships [Relationship.from_opts(opts) | @relationships]
    end
  end

  defmacro has_one(field, opts \\ []) do
    opts = opts
    |> transform_opts(field)
    |> Keyword.put(:type, :to_one)
    |> Keyword.put(:name, field)

    quote bind_quoted: [opts: opts] do
      # macro here to work with opts for building methods?
      @relationships [Relationship.from_opts(opts) | @relationships]
    end
  end

  defp transform_opts(opts, field), do: transform_opts(field, opts, [])

  defp transform_opts(_field, [], opts) do
    opts
  end
  defp transform_opts(field, [{:from, what}|t], opts) do
    use_field = {:using, {:fetch, what}}
    transform_opts(field, t, [use_field|opts])
  end
  defp transform_opts(field, [{:where, expr}|t], opts) when escape_fun?(expr) do
    fun = :"#{field}_where_clause"
    mkfun = {:mkfun, fun}
    transform_opts(field, t, [mkfun|opts])
  end
  defp transform_opts(field, [h|t], opts) do
    transform_opts(field, t, [h|opts])
  end
end
