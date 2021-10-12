defmodule Exbin.Snippet do
  use Exbin.Schema
  import Ecto.Changeset

  schema "snippets" do
    field(:name, :string)
    # empty default to create empty snippets.
    field(:content, :string, default: "")
    field(:viewcount, :integer, default: 0)
    field(:private, :boolean, default: true)
    field(:ephemeral, :boolean, default: false)
    belongs_to :user, Exbin.Accounts.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:content, :name, :viewcount, :private, :ephemeral, :user_id])
    |> validate_required([:name, :content])
    |> unique_constraint(:name)
  end
end
