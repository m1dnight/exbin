defmodule Exbin.Repo.Migrations.SnippetBelongsToUser do
  use Ecto.Migration

  def change do
    alter table(:snippets) do
      add :user_id, references(:users)
    end
  end
end
