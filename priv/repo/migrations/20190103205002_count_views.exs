defmodule ExBin.Repo.Migrations.CountViews do
  use Ecto.Migration

  def change do
    alter table(:snippets) do
      add(:viewcount, :integer, default: 0)
    end
  end
end
