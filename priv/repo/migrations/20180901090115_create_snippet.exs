defmodule Exbin.Repo.Migrations.UpdateSnippet do
  use Ecto.Migration

  def change do
    alter table(:snippets) do
      add(:ephemeral, :boolean, default: false)
    end
  end
end
