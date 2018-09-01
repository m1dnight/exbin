defmodule ExBin.Repo.Migrations.LargeText do
  use Ecto.Migration

  def change do
    alter table(:snippets) do
      modify :content, :text
    end
  end
end
