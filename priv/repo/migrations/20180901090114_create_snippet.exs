defmodule ExBin.Repo.Migrations.CreateSnippet do
  use Ecto.Migration

  def change do
    create table(:snippets) do
      add(:content, :string)
      add(:name, :string, primary_key: true)

      timestamps()
    end

    create(unique_index(:snippets, [:name]))
  end
end
