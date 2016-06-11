defmodule JSON.API.ResourceTest do
  alias JSON.API.Resource

  use ShouldI, async: true

  defmodule LiveStock do
    def id, do: {:fetch, :id}
    def type, do: {:fetch, :class}
    def attributes, do: [name: {:call, [__MODULE__, :name, 1]}]
    def relationships, do: []

    def name(data), do: "#{data.name} the #{data.class}"
  end

  @hampton %{id: 839, name: "hampton", class: "pig"}

  having "a pig named hampton" do
    setup context do
      assign(context, pig: Resource.build(LiveStock, @hampton, nil))
    end

    should "have an id of '839'", %{pig: pig} do
      assert pig.id == "839"
    end

    should "have a type of 'pig'", %{pig: pig} do
      assert pig.type == "pig"
    end

    should "have an attribute name tranformed by name/1", %{pig: pig} do
      assert pig.attributes.name == "hampton the pig"
    end
  end

  having "a generated instruction resource" do
    setup context do
      livestock = Resource.from_opts(
        type: {:fetch, :class},
        attributes: [name: {:fetch, :name}]
      )

      assign context, pig: Resource.build(livestock, @hampton, nil)
    end

    should "have an id of '839'", %{pig: pig} do
      assert pig.id == "839"
    end

    should "have a name of 'hampton'", %{pig: pig} do
      assert pig.attributes.name == "hampton"
    end

    should "have a type of 'pig'", %{pig: pig} do
      assert pig.type == "pig"
    end
  end
end
