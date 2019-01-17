defmodule ExBin.Snippet do
  use Ecto.Schema
  import Ecto.Changeset
  alias ExBin.Snippet

  schema "snippets" do
    field(:name, :string)
    # empty default to create empty snippets.
    field(:content, :string, default: "")
    field(:viewcount, :integer, default: 0)
    timestamps(type: :utc_datetime)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:content, :name, :viewcount])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end

end
