defmodule JSON.APITest do
  use ShouldI, async: true

  defmodule User do
    use JSON.API
    type "user"
    attributes [:name]
    has_many :blog_posts, resource: JSON.APITest.Post
  end

  defmodule Post do
    use JSON.API
    type "post"
    attributes [:tags, :title, :content]
    has_one :author, resource: User
  end

  having "sample data to work with" do
    setup context do
      shallow_user = %{id: 7, name: "Ben"}
      shallow_post = %{id: 12, tags: ~w(foo), title: "FooBar", content: "FooBarBaz"}

      post = Map.put(shallow_post, :author, shallow_user)
      user = Map.put(shallow_user, :blog_posts, [shallow_post])

      context
      |> assign(user: user)
      |> assign(post: post)
    end

    having "built a Post document (has_one) relationship" do
      setup context do
        context
        |> assign(document: JSON.API.build_document(Post, context.post))
      end

      should "have a top level data key", context do
        assert context.document.data
      end

      should "have the id as a string", context do
        assert context.document.data.id == "12"
      end

      should "have a type as a string", context do
        assert context.document.data.type == "post"
      end

      should "have the correct attributes in data", context do
        pairs = context.document.data.attributes |> Enum.to_list
        assert {:title, "FooBar"} in pairs
        assert {:tags, ~w(foo)} in pairs
        assert {:content, "FooBarBaz"} in pairs
        assert Enum.count(pairs) == 3
      end

      should "have relationships in the data", context do
        assert context.document.data.relationships
      end

      should "have an author relationship", context do
        assert context.document.data.relationships.author
      end

      should "have data in the author relationship", context do
        assert context.document.data.relationships.author.data
      end

      should "have a type of 'user' in author Relationship data", context do
        assert context.document.data.relationships.author.data.type == "user"
      end

      should "have an id of '7' in author Relationship data", context do
        assert context.document.data.relationships.author.data.id == "7"
      end
    end

    having "built a User document (has_many) Relationship" do
      setup context do
        context
        |> assign(document: JSON.API.build_document(User, context.user))
      end

      should "have a top level data key", context do
        assert context.document.data
      end

      should "have the id as a string", context do
        assert context.document.data.id == "7"
      end

      should "have a type as a string", context do
        assert context.document.data.type == "user"
      end

      should "have the correct attributes in data", context do
        pairs = context.document.data.attributes |> Enum.to_list
        assert {:name, "Ben"} in pairs
        assert Enum.count(pairs) == 1
      end

      should "have relationships in the data", context do
        assert context.document.data.relationships
      end

      should "have an blog_posts relationship", context do
        assert context.document.data.relationships.blog_posts
      end

      should "have an blog_posts relationship data array", context do
        assert is_list(context.document.data.relationships.blog_posts.data)
      end

      should "have a type of 'post' in blog_posts Relationship data", context do
        relation = context.document.data.relationships.blog_posts.data
        |> List.first

        assert relation.type == "post"
      end

      should "have an id of '12' in blog_posts Relationship data", context do
        relation = context.document.data.relationships.blog_posts.data
        |> List.first

        assert relation.id == "12"
      end
    end
  end
end
