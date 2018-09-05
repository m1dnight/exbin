defmodule ExBin.Logic.Snippet do
  use ExBinWeb, :controller
  alias ExBin.{Snippet, Repo}
  import Ecto.Query

  defp generate_name() do
    name = HorseStapleBattery.generate_compound([:verb, :noun])

    case Repo.one(from s in Snippet, where: s.name == ^name) do
      nil ->
        name

      _ ->
        generate_name()
    end
  end

  @doc """
  Will indefinitely try to insert a snippet.
  """
  def insert(args) do
    try_insert(args, 10)
  end

  defp try_insert(args, attempt) do
    name = generate_name()
    args = Map.merge(args, %{"name" => name})
    changeset = Snippet.changeset(%Snippet{}, args)

    case {Repo.insert(changeset), attempt} do
      {{:error, _e}, 0} ->
        {:error, "failed to insert snippet"}

      {{:error, _e}, _n} ->
        try_insert(args, attempt - 1)

      {{:ok, snippet}, _} ->
        {:ok, snippet}
    end
  end
end
