defmodule ExBin.Repo.Migrations.UtcTs do
  use Ecto.Migration

  def change do
    alter table(:snippets) do
      modify(:inserted_at, :utc_datetime)
      modify(:updated_at, :utc_datetime)
    end
  end
end
