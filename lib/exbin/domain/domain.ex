defmodule ExBin.Domain do
  alias ExBin.{Snippet, Repo}
  import Ecto.Query

  #
  # ### Search
  #

  def search(query) do
    sanitized = LikeInjection.like_sanitize(query)

    query = "%#{sanitized}%"

    from(s in Snippet, where: like(s.content, ^query))
    |> Repo.all()
  end

  #
  # ### Update
  #

  def update_viewcount(snippet, delta \\ 1) do
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
  Gets a snippet by its human readable name.
  """
  def get_by_name(name) do
    from(s in Snippet, where: s.name == ^name)
    |> Repo.one()
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
  def list_public_snippets() do
    from(s in Snippet, where: s.private == false, order_by: [desc: s.inserted_at])
    |> Repo.all()
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
