defmodule ExBin.Snippet do
  use Ecto.Schema
  import Ecto.Changeset
  alias ExBin.Snippet

  schema "snippets" do
    field :content, :string, default: "" # empty default to create empty snippets.
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:content])
    |> validate_required([])
  end
end
