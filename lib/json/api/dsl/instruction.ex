defmodule JSON.API.DSL.Instruction do
  def translate_opts(ast) do
    Macro.prewalk(ast, &translate_node/1)
  end

  defp translate_node({:is, _, [what]}), do: {:use, what}
  defp translate_node({:field, _, [what]}), do: {:fetch, what}
  defp translate_node(any), do: any
end
