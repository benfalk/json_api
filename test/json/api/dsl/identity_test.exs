defmodule JSON.API.DSL.IdentityTest do
  use ShouldI, async: true

  defmodule Foo do
    use JSON.API.DSL.Identity
    type is("foo")
    id field(:uuid)
  end

  defmodule Bar do
    use JSON.API.DSL.Identity
    type "rofl-bar"
    id :bar_id
  end

  should "have a use command with 'foo' for Foo.type" do
    assert Foo.type == {:use, "foo"}
  end

  should "have a fetch command with ':uuid' for Foo.id" do
    assert Foo.id == {:fetch, :uuid}
  end

  should "have a use command with 'rofl-bar' for Bar.type" do
    assert Bar.type == {:use, "rofl-bar"}
  end

  should "have a fetch command with ':bar_id' for Bar.id" do
    assert Bar.id == {:fetch, :bar_id}
  end
end
