defmodule ExBin.Repo.Migrations.Private do
  use Ecto.Migration

  def change do
    alter table(:snippets) do
      add(:private, :boolean, default: true)
    end
  end
end
