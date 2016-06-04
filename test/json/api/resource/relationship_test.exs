defmodule JSON.API.Resource.RelationshipTest do
  use ShouldI, async: true

  defmodule User do
    use JSON.API
    type "user"
    attributes [:name]
    has_many :ponies, type: "pony", where: &(&1.class == "pony"), from: :animals
  end

  having "some user data with animals data loaded in" do
    setup context do
      animals = [
        %{id: 2, class: "pig", name: "wilbur"},
        %{id: 7, class: "pony", name: "charlie"}]
      user = %{id: 4, name: "Cass", animals: animals}

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
end
