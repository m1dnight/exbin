defmodule Exbin.Repo.Migrations.CreateSnippet do
  use Ecto.Migration

  def change do
    create table(:snippets) do
      add(:content, :text)
      add(:name, :string, primary_key: true)
      add(:viewcount, :integer, default: 0)
      add(:private, :boolean, default: true)

      timestamps(type: :utc_datetime_usec)
    end

    create(unique_index(:snippets, [:name]))
    create(index(:snippets, ["length(content)"]))
    # create(index(:snippets, ["DATE(inserted_at AT TIME ZONE 'UTC')"]))
  end
end
