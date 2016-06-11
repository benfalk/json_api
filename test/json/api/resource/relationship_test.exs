defmodule JSON.API.Resource.RelationshipTest do
  use ShouldI, async: true

  defmodule Pony do
    use JSON.API
    type "pony"
    attributes [:name]
  end

  defmodule User do
    use JSON.API
    type "user"
    attributes [:name]
    has_many :ponies, resource: Pony, where: &(&1.class == "pony"), from: :animals
  end

  defmodule Farmer do
    use JSON.API
    type "farmer"
    attributes [:name]
    has_many :livestock, type: field(:class), from: :animals
  end

  @animals [
    %{id: 2, class: "pig", name: "wilbur"},
    %{id: 7, class: "pony", name: "charlie"}
  ]

  having "some user data with animals data loaded in" do
    setup context do
      user = %{id: 4, name: "Cass", animals: @animals}

      context
      |> assign(user: JSON.API.build_document(User, user).data)
    end

    should "have a 'relationships.ponies' object", %{user: user} do
      assert is_map(user.relationships.ponies)
    end

    should "have a pony in the relationship data", %{user: user} do
      assert user.relationships.ponies.data == [%{id: "7", type: "pony"}]
    end
  end

  having "some farmer data with animals data loaded in" do
    setup context do
      user = %{id: 4, name: "Cass", animals: @animals}

      context
      |> assign(user: JSON.API.build_document(Farmer, user).data)
    end

    should "have livestock with different types", %{user: user} do
      types = user.relationships.livestock.data |> Enum.map(&(&1.type))
      assert "pig" in types
      assert "pony" in types
    end
  end
end
