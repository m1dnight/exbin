defmodule ExBin.Repo.Migrations.CreateSnippet do
  use Ecto.Migration

  def change do
    create table(:snippets) do
      add :content, :string

      timestamps()
    end
  end
end
