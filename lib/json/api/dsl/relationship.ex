defmodule JSON.API.DSL.Relationship do
  alias JSON.API.Resource.Relationship
  import FunkyFunc

  defmacro __using__(_) do
    quote do
      import FunkyFunc, only: [package_funs: 1]
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
    add_relationship(field, :to_many, opts)
  end

  defmacro has_one(field, opts \\ []) do
    add_relationship(field, :to_one, opts)
  end

  defp add_relationship(field, type, opts) do
    opts = opts
    |> escape_fun_list
    |> transform_opts(field)
    |> Keyword.put(:type, type)
    |> Keyword.put(:name, field)

    funs = for {:mkfun, fun} <- opts, do: fun

    quote do
      @relationships [Relationship.from_opts(unquote(opts)++[{:owner, __MODULE__}]) | @relationships]
      package_funs unquote(funs)
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
  defp transform_opts(field, [{:where, expr}|t], opts) when escaped_fun?(expr) do
    fun = :"#{field}_where_clause"
    mkfun = {:mkfun, {fun, expr}}
    filter = {:filter, {:call, {fun, arity(expr)}}}
    transform_opts(field, t, opts ++ [mkfun, filter])
  end
  defp transform_opts(field, [h|t], opts) do
    transform_opts(field, t, [h|opts])
  end
end
