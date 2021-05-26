defmodule ExBin.Domain do
  alias ExBin.{Snippet, Repo}
  import Ecto.Query
  require Logger

  #
  # ### Search
  #

  def search(query) do
    sanitized = LikeInjection.like_sanitize(query)
    Logger.debug("Query: #{query}, sanitied: #{sanitized}")
    parameter = "%#{sanitized}%"

    Logger.debug("Query: `#{query}`, sanitized: `#{sanitized}`, parameter: `#{parameter}`")

    from(s in Snippet, where: like(s.content, ^parameter) and s.private == false, order_by: [desc: s.inserted_at])
    |> Repo.all()
  end

  #
  # ### Update
  #

  def update_viewcount(snippet, delta \\ 1) do
    # Note that this will not update every time because of the caching on the snippets!
    Repo.transaction(fn ->
      s = Repo.get!(Snippet, snippet.id)
      s = Snippet.changeset(s, %{viewcount: s.viewcount + delta})
      Repo.update!(s)
    end)
  end

  #
  # ### Create
  #

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
      Repo.insert!(changeset)
    end)
  end

  #
  # ### List
  #

  @doc """
  Checks if the snippet is in the cache, if so returns it.
  If not, gets it from the repo and caches it.
  """
  defp snippet_from_cache_or_repo(name) do
    ConCache.get_or_store(:snippet_cache, name, fn ->
      from(s in Snippet, where: s.name == ^name)
      |> Repo.one()
    end)
  end

  @doc """
  Gets a snippet by its human readable name.
  """
  def get_by_name(name) do
    snippet_from_cache_or_repo(name)
  end

  @doc """
  Grabs the newest snippet from the database.
  """
  def last_snippet() do
    first(from(s in Snippet, where: s.private == false, order_by: [desc: s.inserted_at]))
    |> Repo.one()
  end

  @doc """
  List all snippets.
  """
  def list_snippets() do
    Repo.all(Snippet)
  end

  @doc """
  List all public snippets.
  """
  def list_public_snippets(limit \\ nil) do
    case limit do
      nil ->
        from(s in Snippet, where: s.private == false, order_by: [desc: s.inserted_at])
        |> Repo.all()

      n ->
        from(s in Snippet, where: s.private == false, order_by: [desc: s.inserted_at], limit: ^n)
        |> Repo.all()
    end
  end

  @doc """
  List all private snippets.
  """
  def list_private_snippets() do
    from(s in Snippet, where: s.private == true, order_by: [desc: s.inserted_at])
    |> Repo.all()
  end

  @doc """
  Count all the private snippets.
  """
  def count_private_snippets() do
    Repo.one(from(s in Snippet, where: s.private == true, select: count(s.id)))
  end

  @doc """
  Count all the private snippets.
  """
  def count_public_snippets() do
    Repo.one(from(s in Snippet, where: s.private == false, select: count(s.id)))
  end

  #
  # ### Private
  #

  # @doc """
  # Generates a human-readable name that is not yet present in the database.
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
