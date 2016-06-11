defmodule JSON.API.DSL.Relationship do
  alias JSON.API.Resource.Relationship
  alias JSON.API.DSL
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
    info = %{field: field, module: __CALLER__.module}
    add_relationship(info, :to_many, opts)
  end

  defmacro has_one(field, opts \\ []) do
    info = %{field: field, module: __CALLER__.module}
    add_relationship(info, :to_one, opts)
  end

  defp add_relationship(info, type, opts) do
    opts = opts
    |> DSL.Instruction.translate_opts
    |> escape_fun_list
    |> decide_resource
    |> transform_opts(info)
    |> Keyword.put(:type, type)
    |> Keyword.put(:name, info.field)

    funs = for {:mkfun, fun} <- opts, do: fun

    quote do
      @relationships [Relationship.from_opts(unquote(opts)) | @relationships]
      package_funs unquote(funs)
    end
  end

  defp transform_opts(opts, info), do: transform_opts(info, opts, [])

  defp transform_opts(_info, [], opts) do
    opts
  end
  defp transform_opts(info, [{:from, what}|t], opts) do
    use_field = {:using, {:fetch, what}}
    transform_opts(info, t, [use_field|opts])
  end
  defp transform_opts(info, [{:where, expr}|t], opts) when escaped_fun?(expr) do
    fun = :"#{info.field}_where_clause"
    mkfun = {:mkfun, {fun, expr}}
    filter = {:filter, {:call, [info.module, fun, arity(expr)]}}
    transform_opts(info, t, opts ++ [mkfun, filter])
  end
  defp transform_opts(info, [h|t], opts) do
    transform_opts(info, t, [h|opts])
  end

  defp decide_resource(opts) do
    resource = JSON.API.Resource.from_opts(opts)
    Keyword.put_new(opts, :resource, Macro.escape(resource))
  end
end
