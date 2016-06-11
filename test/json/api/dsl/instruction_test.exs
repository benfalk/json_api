defmodule JSON.API.DSL.InstructionTest do
  use ShouldI, async: true

  require JSON.API.DSL.Instruction
  alias JSON.API.DSL.Instruction

  having "transformed some options" do
    setup context do
      assign context, opts: Instruction.translate_opts(quote do: [
        first_name: field(:fname),
        last_name: field(:lname),
        middle_name: is("N/A")
      ])
    end

    should "contain a fetch instruction for first_name", %{opts: opts} do
      assert opts[:first_name] == {:fetch, :fname}
    end

    should "contain a fetch instruction for last_name", %{opts: opts} do
      assert opts[:last_name] == {:fetch, :lname}
    end

    should "contain a use instruction for middle_name", %{opts: opts} do
      assert opts[:middle_name] == {:use, "N/A"}
    end
  end
end
