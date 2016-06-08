defmodule JSON.API.Instruction do
  @moduledoc """
  Provides a centralized concept in which data is executed on with the
  different JSON.API modules.
  """
  # Fetch a key directly from data
  def run({:fetch, key}, data, _), do: Map.get(data, key)

  # Use a given static value
  def run({:use, value}, _, _), do: value

  # Dynamic call to a function
  def run({:call, [module, func, 0]}, _, _),
    do: apply(module, func, [])
  def run({:call, [module, func, 1]}, data, _),
    do: apply(module, func, [data])
  def run({:call, [module, func, 2]}, data, context),
    do: apply(module, func, [data, context])
end
