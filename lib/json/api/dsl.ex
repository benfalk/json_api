defmodule JSON.API.DSL do
  defmacro __using__(_) do
    quote do
      use JSON.API.DSL.Relationship
      use JSON.API.DSL.Identity
      use JSON.API.DSL.Attribution
    end
  end
end
