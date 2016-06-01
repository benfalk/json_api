defmodule JSON.API.Resource.Default do
  def id, do: {:fetch, :id}
  def type, do: {:use, ""}
  def attributes, do: []
end
