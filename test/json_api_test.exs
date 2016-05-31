defmodule JSON.APITest do
  use ShouldI, async: true

  defmodule User do
    use JSON.API
    type "user"
    attributes [:name]
    has_many :blog_posts, resource: Post
  end

  defmodule Post do
    use JSON.API
    type "post"
    attributes [:tags, :title, :content]
    has_one :author, resource: User
  end

  having "sample data to work with" do
    setup context do
      user = %{id: 7, name: "Ben"}
      post = %{id: 12, tags: ~w(foo), title: "FooBar",
               content: "FooBarBaz", author: user}

      context
      |> assign(user: user)
      |> assign(post: post)
    end

    having "built a Post document" do
      setup context do
        context
        |> assign(document: JSON.API.build_document(Post, context.post))
      end

      should "have a top level data key", context do
        assert context.document.data
      end

      should "have the id as a sting", context do
        assert context.document.data.id == "12"
      end

      should "have a type as a string", context do
        assert context.document.data.type == "post"
      end

      should "have the correct attributes in data", context do
        pairs = context.document.data.attributes |> Enum.to_list
        assert {:title, "FooBar"} in pairs
      end
    end
  end
end
