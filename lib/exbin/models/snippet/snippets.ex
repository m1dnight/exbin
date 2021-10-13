defmodule Exbin.Snippets do
  require Logger
  import Ecto.Query
  alias Exbin.{Snippet, Repo}

  #############################################################################
  # Search

  def search(query) do
    sanitized = LikeInjection.like_sanitize(query)
    Logger.debug("Query: #{query}, sanitized: #{sanitized}")
    parameter = "%#{sanitized}%"

    Logger.debug("Query: `#{query}`, sanitized: `#{sanitized}`, parameter: `#{parameter}`")

    from(s in Snippet, where: ilike(s.content, ^parameter) and s.private == false, order_by: [desc: s.inserted_at])
    |> Repo.all()
  end

  def search(query, user_id) do
    sanitized = LikeInjection.like_sanitize(query)
    Logger.debug("Query: #{query}, sanitized: #{sanitized}")
    parameter = "%#{sanitized}%"

    Logger.debug("Query: `#{query}`, sanitized: `#{sanitized}`, parameter: `#{parameter}`")

    from(s in Snippet,
      where: ilike(s.content, ^parameter) and s.user_id == ^user_id,
      or_where: ilike(s.content, ^parameter) and s.private == false,
      order_by: [desc: s.inserted_at]
    )
    |> Repo.all()
  end

  #############################################################################
  # Insert

  def change_snippet(%Snippet{} = snippet) do
    Snippet.changeset(snippet, %{})
  end

  @doc """
  Inserts a new snippet into the database.
  args: %{"content" => "text", "private" => "false"}
  """
  def insert(args) do
    Repo.transaction(fn ->
      # Generate a unique name.
      name = generate_name()
      args = Map.merge(args, %{"name" => name})

      # Insert.
      changeset = Snippet.changeset(%Snippet{}, args)
      IO.inspect(args, label: "args")
      IO.inspect(changeset, label: "changeset")
      Repo.insert!(changeset)
    end)
  end

  #############################################################################
  # Delete

  @doc """
  Deletes a snippet.
  """
  def delete_snippet(%Snippet{} = snippet) do
    Repo.delete(snippet)
  end

  @doc """
  Deletes all snippets that are older than `age` minutes and are ephemeral.
  """
  def scrub(age) do
    now = DateTime.utc_now()

    q =
      from s in Snippet,
        where: s.ephemeral == true,
        where: fragment("? - ? > ? * interval '1 minutes'", ^now, s.inserted_at, ^age)

    Repo.delete_all(q)
  end

  #############################################################################
  # Update

  @doc """
  Increments the viewcount of a snippet by 1 (or more).
  """
  def update_viewcount(snippet, delta \\ 1) do
    # Note that this will not update every time because of the caching on the snippets!
    Repo.transaction(fn ->
      s = Repo.get!(Snippet, snippet.id)
      s = Snippet.changeset(s, %{viewcount: s.viewcount + delta})
      Repo.update!(s)
    end)
  end

  #############################################################################
  # Read

  @doc """
  List all snippets.
  """
  def list_public_snippets() do
    list_snippets(filter: :public)
  end

  def list_private_snippets() do
    list_snippets(filter: :private)
  end

  def list_snippets(opts \\ []) do
    limit = Keyword.get(opts, :limit, nil)
    filter = Keyword.get(opts, :filter, :all)

    q = from(s in Snippet, order_by: [desc: s.inserted_at])

    q =
      if limit do
        q
        |> limit(^limit)
      else
        q
      end

    q =
      case filter do
        :all ->
          q

        :private ->
          q
          |> where([s], s.private == true)

        :public ->
          q
          |> where([s], s.private == false)
      end

    Repo.all(q)
  end

  @doc """
  Gets a snippet by its human readable name.
  """
  def get_by_name(name) do
    snippet =
      from(s in Snippet, where: s.name == ^name)
      |> Repo.one()

    case snippet do
      nil ->
        {:error, :not_found}

      snippet ->
        {:ok, snippet}
    end
  end

  def get_by_id(id) do
    snippet =
      from(s in Snippet, where: s.id == ^id)
      |> Repo.one()

    case snippet do
      nil ->
        {:error, :not_found}

      snippet ->
        {:ok, snippet}
    end
  end

  def list_user_snippets(user_id, opts \\ []) do
    limit = Keyword.get(opts, :limit, nil)

    q =
      from(s in Snippet, order_by: [desc: s.inserted_at])
      |> where([s], s.user_id == ^user_id)
      |> limit(^limit)

    Repo.all(q)
  end

  @doc """
  Count all the snippets.
  """
  def count_snippets() do
    Repo.one(from(s in Snippet, select: count(s.id)))
  end

  #############################################################################
  # Helpers

  # @doc """
  # Generates a human-readable name that is not yet present in the database.
  # In theory this function can run forever, but in practice it doesn't.
  # """
  defp generate_name() do
    name = HorseStapleBattery.generate_compound([:verb, :noun])

    case Repo.one(from(s in Snippet, where: s.name == ^name)) do
      nil ->
        name

      _ ->
        generate_name()
    end
  end
end
